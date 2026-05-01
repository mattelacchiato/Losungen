// Tiny CLI that uploads a local file to a connected MTP device using
// the same Go MTP stack OpenMTP uses (github.com/ganeshrvel/go-mtpx).
//
// Usage:
//   mtp-upload <local-file> <remote-dir>
//
// The remote dir is relative to the MTP storage root, e.g. "/GARMIN/Apps".
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	mtpx "github.com/ganeshrvel/go-mtpx"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintf(os.Stderr, "usage: %s <local-file> <remote-dir>\n", filepath.Base(os.Args[0]))
		os.Exit(2)
	}
	localFile, remoteDir := os.Args[1], os.Args[2]

	absLocal, err := filepath.Abs(localFile)
	must("resolve local path", err)
	if _, err := os.Stat(absLocal); err != nil {
		die("local file not readable: %v", err)
	}

	if !strings.HasPrefix(remoteDir, "/") {
		remoteDir = "/" + remoteDir
	}

	dev, err := mtpx.Initialize(mtpx.Init{DebugMode: false})
	must("connect to MTP device", err)
	defer mtpx.Dispose(dev)

	storages, err := mtpx.FetchStorages(dev)
	must("fetch storages", err)
	if len(storages) == 0 {
		die("device has no storage")
	}
	storageId := storages[0].Sid

	fmt.Fprintf(os.Stderr, "Uploading %s -> %s%s\n",
		filepath.Base(absLocal), remoteDir, "/"+filepath.Base(absLocal))

	_, _, _, err = mtpx.UploadFiles(
		dev,
		storageId,
		[]string{absLocal},
		remoteDir,
		false,
		func(_ *os.FileInfo, _ string, err error) error { return err },
		func(pi *mtpx.ProgressInfo, err error) error {
			if err != nil {
				return err
			}
			if pi != nil && pi.ActiveFileSize != nil && pi.ActiveFileSize.Total > 0 {
				fmt.Fprintf(os.Stderr, "\r  %d / %d bytes (%.0f%%)   ",
					pi.ActiveFileSize.Sent,
					pi.ActiveFileSize.Total,
					pi.ActiveFileSize.Progress)
			}
			return nil
		},
	)
	fmt.Fprintln(os.Stderr)
	if err != nil {
		die("upload failed: %v", err)
	}
	fmt.Fprintln(os.Stderr, "Done.")
}

func must(what string, err error) {
	if err != nil {
		die("%s: %v", what, err)
	}
}

func die(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "ERROR: "+format+"\n", args...)
	os.Exit(1)
}
