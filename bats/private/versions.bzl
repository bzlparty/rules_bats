"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
  "1.10.0": "sha384-0bECvZUpBRV3qescdNMrjhDvYs6gbENznIQmn3ctNlL5RPnw6z3bxfLUU0QC8Qic",
}
