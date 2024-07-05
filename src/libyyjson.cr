@[Link(ldflags: "#{__DIR__}/ext/libyyjson.a")]
lib LibYYJSON
  struct Document
    root : Val*
    alc : Void*
    dat_read : LibC::SizeT
    val_read : LibC::SizeT
    str_pool : LibC::Char*
  end

  struct Val
    tag : UInt64
    uni : JSONPayloadType
  end

  union JSONPayloadType
    u64 : UInt64
    i64 : Int64
    f64 : LibC::Double
    str : LibC::Char*
    ptr : Void*
    ofs : LibC::SizeT
  end

  struct YYJSONReadError
    code : UInt32
    message: LibC::Char*
    pos : LibC::SizeT
  end

  struct ObjIter
    idx : LibC::SizeT # Next key's index
    max : LibC::SizeT # Max key index
    cur : Val # Value of the next key
    obj : Val # The object being iterated
  end

  fun yyjson_read_opts(dat : LibC::Char*, len : LibC::SizeT, flg : UInt32, alc : Void*, err : YYJSONReadError*) : Document*
  fun yyjson_obj_iter_init(obj : Val*, iter : ObjIter*) : Bool
  fun yyjson_obj_iter_next(iter : ObjIter*) : Val*
  fun yyjson_obj_iter_get_val(key : Val*) : Val*
end
