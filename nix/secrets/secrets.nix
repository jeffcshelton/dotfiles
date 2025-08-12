let
  keys = import ../keys;
in
{
  "cloudflare-2ef66204-58a9-4489-ba95-e1422803e192.json.age".publicKeys = [
    keys.mars.system
  ];
}
