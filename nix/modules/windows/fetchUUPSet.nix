{ aria2, cacert, curl, jq, stdenv, ... }:
let

  uup = { uuid, edition, lang, sha256 }: stdenv.mkDerivation {
    name = "uup-set-${uuid}";

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = sha256;

    nativeBuildInputs = [ aria2 cacert curl jq ];

    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    buildCommand = ''
      API_URL="https://api.uupdump.net/get.php?id=${uuid}&lang=${lang}&edition=${edition}"

      curl --fail "$API_URL" -o response.json || {
        echo "Error: Failed to contact UUP Dump API."
        exit 1
      }

      if jq -e '.response.error' response.json > /dev/null; then
        echo "API Error: $(jq -r '.response.error' response.json)"
        exit 1
      fi

      jq -r '.response.files | to_entries[] | "\(.value.url)\n  out=\(.key)\n  checksum=sha-256=\(.value.sha256)"' response.json > download_list.txt

      mkdir -p $out

      aria2c -i download_list.txt \
        -d $out \
        -j16 -x16 -s16 \
        --auto-file-renaming=false \
        --allow-overwrite=true \
        --check-certificate=true
    '';
  };
in
uup
