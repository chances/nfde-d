import std.stdio;

import nfde;

void main() {
  import std.conv : text;

  string path;

  "Prompting the user to open a file...".writeln;
  auto result = openDialog(path, []);
  assert(result != Result.error, getError());
  (result.text ~ ": " ~ path).writeln;

  "Prompting the user to pick a folder...".writeln;
  result = pickFolder(path);
  assert(result != Result.error, getError());
  (result.text ~ ": " ~ path).writeln;
}
