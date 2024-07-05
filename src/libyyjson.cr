@[Link("yyjson")]
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

  fun yyjson_read_opts(dat : LibC::Char*, len : LibC::SizeT, flg : UInt32, alc : Void*, err : YYJSONReadError*) : Document*
  end
