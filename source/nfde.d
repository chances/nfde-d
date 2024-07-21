module nfde;

import core.stdc.limits : PATH_MAX;
import core.stdc.string : strlen;
import std.conv : asOriginalType, to;
import std.string : toStringz;

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

///
string getError() {
  auto error = NFD_GetError();
  if (error !is null) NFD_ClearError();
  return error is null ? null : error.to!string.idup;
}

///
alias FilterItem = nfdnfilteritem_t;

///
Result openDialog(out string path, FilterItem[] filters, string defaultPath = null) {
  nfdchar_t* outPath;

  auto response = NFD_OpenDialogN(&outPath, filters.ptr, filters.length.to!uint, defaultPath.toStringz);
  if (response.asOriginalType == Result.okay) {
    const selectedPath = outPath[0 .. outPath.strlen].to!string.idup;
    NFD_FreePathN(outPath);
    path = selectedPath;
  }
  return response.asOriginalType.to!Result;
}

// TODO: NFD_OpenDialogN_With

///
Result openDialogMultiple(out PathSet paths, FilterItem[] filters, string defaultPath = null) {
  PathSet outPaths;

  auto response = NFD_OpenDialogMultipleN(outPaths.ptr, filters.ptr, filters.length.to!uint, defaultPath.toStringz);
  paths = outPaths;
  return response.asOriginalType.to!Result;
}

// TODO: NFD_OpenDialogMultipleN_With

///
Result saveDialog(out string path, FilterItem[] filters, string defaultName = null, string defaultPath = null) {
  nfdchar_t* savePath;

  auto response = NFD_SaveDialogN(
    &savePath, filters.ptr, filters.length.to!uint, defaultPath.toStringz, defaultName.toStringz
  );
  if (response.asOriginalType == Result.okay) {
    const selectedPath = savePath[0 .. savePath.strlen].to!string.idup;
    NFD_FreePathN(savePath);
    path = selectedPath;
  }
  return response.asOriginalType.to!Result;
}

// TODO: NFD_SaveDialogN_With

///
Result pickFolder(out string path, string defaultPath = null) {
  nfdchar_t* outPath;

  auto response = NFD_PickFolderN(&outPath, defaultPath.toStringz);
  if (response.asOriginalType == Result.okay) {
    const selectedPath = outPath[0 .. outPath.strlen].to!string.idup;
    NFD_FreePathN(outPath);
    path = selectedPath;
  }
  return response.asOriginalType.to!Result;
}

// TODO: NFD_PickFolderN_With

///
alias PathSetSize = nfdpathsetsize_t;

///
struct PathSet {
  package nfdpathset_t* set;

  ~this() {
    NFD_PathSet_Free(set);
  }

  const(void)** ptr() const @property {
    import std.conv : castFrom;
    return castFrom!(const void*).to!(const(void)**)(set);
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
