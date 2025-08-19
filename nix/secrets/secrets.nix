let
  keys = import ../keys;
in
{
  "cloudflare-2ef66204-58a9-4489-ba95-e1422803e192.json.age".publicKeys = [
    keys.mars.system
  ];

  "cloudflare-8d3020bb-f23e-4689-80c2-0e8344bfbd09.json.age".publicKeys = [
    keys.venus.system
  ];
}
