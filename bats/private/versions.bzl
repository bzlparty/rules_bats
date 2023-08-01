"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "bats-core": {
        "1.10.0": "sha384-0bECvZUpBRV3qescdNMrjhDvYs6gbENznIQmn3ctNlL5RPnw6z3bxfLUU0QC8Qic",
    },
    "bats-assert": {
        "2.1.0": "sha384-Zqcgs3Kzg7AuYk8JQH890FJS0PcEXhbFdtZtC8qpsWxCTYAA7krXWwlT139G2nwq",
    },
    "bats-support": {
        "0.3.0": "sha384-+KeaxrxTiakMKBY8jumpjrkVfnEYOBhnToTgnN9b3vGPWg9C/gO6qzYUFhbt9Nft",
    },
}
