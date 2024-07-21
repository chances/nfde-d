module nfde;

import core.stdc.limits : PATH_MAX;
import std.conv : to;

import nfde_bindings;

package auto isInitialized = false;

static this() {
  isInitialized = (NFD_Init() == NFD_OKAY);
  assert(isInitialized, "NFDE was not initialized!");
}
static ~this() {
  if (isInitialized) NFD_Quit();
}

///
enum Result : int {
  ///
  error,
  ///
  okay,
  ///
  cancel
}

string getError() {
  auto error = NFD_GetError();
  if (error !is null) NFD_ClearError();
  return error is null ? null : error.to!string.idup;
}

///
alias FilterItem = nfdnfilteritem_t;

///
Result openDialog(out string path, FilterItem[] filters, string defaultPath = null) {
  import std.conv : castFrom;

  string selectedPath = new char[PATH_MAX];
  auto response = NFD_OpenDialogN(
    castFrom!(string*).to!(nfdnchar_t**)(&selectedPath),
    filters.ptr, filters.length.to!uint,
    defaultPath.ptr
  );
  path = selectedPath;
  return response.to!uint.to!Result;
}

///
Result openDialogMultiple() {
  assert(0, "Unimplemented!");
}

///
Result saveDialog() {
  assert(0, "Unimplemented!");
}

///
Result pickFolder() {
  assert(0, "Unimplemented!");
}

///
alias PathSetSize = nfdpathsetsize_t;

///
struct PathSet {
  import std.conv : asOriginalType;

  package nfdpathset_t* set;

  ~this() {
    NFD_PathSet_Free(set);
  }

  ///
  ulong length() const @property {
    ulong count;
    assert(NFD_PathSet_GetCount(set, &count).asOriginalType == Result.okay);
    return count;
  }

  // TODO: Implement an enumerator interface with std.slice: NFD_PathSet_GetEnum, NFD_PathSet_EnumNextN, NFD_PathSet_FreeEnum

  ///
  string opIndex(size_t i) {
    assert(i >= 0 && i < this.length);
    auto path = new nfdnchar_t[PATH_MAX];
    auto pathPtr = path.ptr;
    assert(NFD_PathSet_GetPathN(set, i, &pathPtr).asOriginalType == Result.okay);
    // TODO: NFD_PathSet_FreePathN
    return path.to!string;
  }

  /// Returns: UTF-8 path at offset, `index`.
  string pathAt(size_t index) {
    assert(index >= 0 && index < this.length);
    auto path = new nfdu8char_t[PATH_MAX];
    auto pathPtr = path.ptr;
    assert(NFD_PathSet_GetPathU8(set, index, &pathPtr).asOriginalType == Result.okay);
    // TODO: NFD_PathSet_FreePathU8
    return path.to!string;
  }
}
