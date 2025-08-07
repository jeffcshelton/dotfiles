let
  jeff = builtins.readFile ./keys/jeff.pub;
  mars = builtins.readFile ./keys/mars.pub;
in
{
  "cloudflare/0d022530-69c4-4af0-9b80-a82c25918361.json.age".publicKeys = [ mars ];
}
