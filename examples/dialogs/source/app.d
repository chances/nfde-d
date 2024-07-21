import std.stdio;

import nfde;

void main() {
  import std.conv : text;

  "Prompting the user to open a file...".writeln;

  string path;
  auto result = openDialog(path, []);
  assert(result != Result.error, getError());
  (result.text ~ ": " ~ path).writeln;
}
