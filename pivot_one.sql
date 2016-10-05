create table t1( c1 varchar2(10), c2 varchar2(10), c3 number(5) );

insert into t1 values ( 'aaaa', 'col1', 3 );
insert into t1 values ( 'aaaa', 'col2', 13 );
insert into t1 values ( 'aaaa', 'col3', 6 );
insert into t1 values ( 'bbbb', 'col1', 2 );
insert into t1 values ( 'bbbb', 'col2', 23 );
insert into t1 values ( 'bbbb', 'col3', 123 );
insert into t1 values ( 'cccc', 'col1', 241 );
insert into t1 values ( 'cccc', 'col2', 0 );
insert into t1 values ( 'cccc', 'col3', 36 );

select c1
     , max( decode( c2, 'col1', c3 ) ) col1
     , max( decode( c2, 'col2', c3 ) ) col2
     , max( decode( c2, 'col3', c3 ) ) col3
from t1
group by c1


create or replace type PivotImpl as object 
( 
  ret_type anytype,      -- The return type of the table function
  rows_returned number,  -- The number of rows currently returned by the table function
  static function ODCITableDescribe( rtype out anytype, dummy in number )
  return number, 
  static function ODCITablePrepare( sctx out PivotImpl, ti in sys.ODCITabFuncInfo, dummy in number )
  return number, 
  static function ODCITableStart( sctx in out PivotImpl, dummy in number )
  return number, 
  member function ODCITableFetch( self in out PivotImpl, nrows in number, outset out anydataset )
  return number,
  member function ODCITableClose( self in PivotImpl )
  return number,
  static function show( dummy in number )
  return anydataset pipelined using PivotImpl
);
/ 

create or replace type body PivotImpl as 
  static function ODCITableDescribe( rtype out anytype, dummy in number )
  return number
  is
    atyp anytype; 
  begin 
    anytype.begincreate( dbms_types.typecode_object, atyp );
    atyp.addattr( 'C1'
                , dbms_types.typecode_varchar2
                , null
                , null
                , 10
                , null
                , null
                ); 
    for r_t1 in ( select distinct upper( c2 ) c2 from t1 order by upper( c2 ) )
    loop 
      atyp.addattr( r_t1.c2
                  , dbms_types.typecode_number
                  , 10
                  , 0
                  , null
                  , null
                  , null
                  ); 
    end loop; 
    atyp.endcreate; 
    anytype.begincreate( dbms_types.typecode_table, rtype ); 
    rtype.SetInfo( null, null, null, null, null, atyp, dbms_types.typecode_object, 0 ); 
    rtype.endcreate(); 
    return odciconst.success;
  exception
    when others then
      return odciconst.error;
  end;   
--
  static function ODCITablePrepare( sctx out PivotImpl, ti in sys.ODCITabFuncInfo, dummy in number )
  return number
  is 
    prec     pls_integer; 
    scale    pls_integer; 
    len      pls_integer; 
    csid     pls_integer; 
    csfrm    pls_integer; 
    elem_typ anytype; 
    aname    varchar2(30); 
    tc       pls_integer; 
  begin 
    tc := ti.RetType.GetAttrElemInfo( 1, prec, scale, len, csid, csfrm, elem_typ, aname ); 
    sctx := PivotImpl( elem_typ, 0 ); 
    return odciconst.success; 
  end; 
--
  static function ODCITableStart( sctx in out PivotImpl, dummy in number )
  return number
  is
  begin 
    return odciconst.success; 
  end; 
--
  member function ODCITableFetch( self in out PivotImpl, nrows in number, outset out anydataset )
  return number
  is
    type_code   pls_integer;
    prec        pls_integer;
    scale       pls_integer;
    len         pls_integer;
    csid        pls_integer;
    csfrm       pls_integer;
    schema_name varchar2(30);
    type_name   varchar2(30);
    version     varchar2(30);
    attr_count  pls_integer;
    attr_type   anytype;
    attr_name   varchar2(30);
    cursor c_t1( b1 varchar2, b2 varchar2 )
    is
      select c3
      from t1
      where c1 = b1
      and   upper( c2 ) = b2;
    t_c3 number(10);
  begin 
    outset := null;
    if self.rows_returned = 0
    then
      anydataset.begincreate( dbms_types.typecode_object, self.ret_type, outset ); 
/* I don't look at nrows (= the number of rows requested), but always return all rows. */
      type_code := self.ret_type.getinfo( prec
                                        , scale
                                        , len
                                        , csid
                                        , csfrm
                                        , schema_name
                                        , type_name
                                        , version
                                        , attr_count
                                        );
      for r_t1 in ( select distinct c1 from t1 )
      loop 
        outset.addinstance;
        outset.piecewise(); 
        outset.setvarchar2( r_t1.c1 ); 
        for i in 2 .. attr_count
        loop
          type_code := self.ret_type.getattreleminfo( i
                                                    , prec
                                                    , scale
                                                    , len
                                                    , csid
                                                    , csfrm
                                                    , attr_type
                                                    , attr_name
                                                    );
          open c_t1( r_t1.c1, attr_name );
          fetch c_t1 into t_c3;
          if c_t1%found
          then
            outset.setnumber( t_c3 ); 
          else
            outset.setnumber( null ); 
          end if;
          close c_t1;
        end loop;
        self.rows_returned := self.rows_returned + 1;
      end loop;
      outset.endcreate; 
    end if;

    return odciconst.success; 
  end; 
--  
  member function ODCITableClose( self in PivotImpl )
  return number
  is
  begin
    return odciconst.success; 
  end; 
end; 
/

select * from table( pivotimpl.show(  7 ) )
