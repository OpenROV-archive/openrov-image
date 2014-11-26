Adding a file manually to the repository
===

   upload-file.sh -c /<path>/<credentials> <file to upload>

The files are by default uploaded into the test directory of the bucket.
To upload a file to production use the ``-p`` or ``--production`` flag.
The script will ask for confirmation, this can be overriden with ``-f|--force``.

For more parameters run:

	upload-file.sh --help



Deleting a file from the repository
===

	delete-package.sh -c /<path>/<credentials> -v <0.0.9> <package-name>

The package will, by default, be delete from the test directory of the bucket.
To delete a file from production use the ``-p|--production`` flag.
The script will ask for confirmation, this can be overriden with ``-f|--force``.

For more parameters run:

	delete-package.sh --help

