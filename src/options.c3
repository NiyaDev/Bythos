
module bythos;

// Structs
struct Option {
  OptionType type;
  union value {
    bool as_bool;
    
    ichar as_schar;
    short as_sshort;
    int as_sint;
    long as_slong;

    char as_uchar;
    ushort as_ushort;
    uint as_uint;
    ulong as_ulong;

    float as_float;
    double as_double;

    // Array?
  }
}

// Enums
enum OptionType {
  BOOL,

  SBYTE,
  SSHORT,
  SINT,
  SLONG,

  UBYTE,
  USHORT,
  UINT,
  ULONG,

  FLOAT,
  DOUBLE,

  ARRAY,
}

