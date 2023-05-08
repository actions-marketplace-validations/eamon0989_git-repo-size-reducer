import { createReadStream, createWriteStream } from "node:fs";
import { resolve } from "node:path";
import { Transform } from "node:stream";
import { pipeline } from "node:stream/promises";
import { setFailed } from "@actions/core";

const pathToAnalysisFile = `.git/filter-repo/analysis/path-deleted-sizes.txt`;
const writePath = `files-to-delete.txt`;
const objectsToFilterRegexp = new RegExp(/(?<=\d{4}-\d{2}-\d{2}\s)(\S+\n)/g);

/* 
This script will create a file called files-to-delete.txt in the root of the project.
It relies on the analysis file (`git/filter-repo/analysis/path-deleted-sizes.txt`) created by 
running git-filter-repo git --analyze.

Docs for git-filter-repo: https://github.com/newren/git-filter-repo
*/

(async () => {
	try {
		const stream = createReadStream(resolve(pathToAnalysisFile));
		const writeStream = createWriteStream(resolve(writePath), "utf8");

		const filepathStream = new Transform({
			transform(data, _encoding, callback) {
				const matches = data.toString()?.match(objectsToFilterRegexp);
				callback(null, matches?.join("\n"));
			},
		});

		await pipeline(stream, filepathStream, writeStream);
	} catch (error) {
		setFailed(error.message);
	}
})();
