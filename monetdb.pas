unit MonetDBAPI;
// 64 bit only

interface


const
  MonetDBAPILib = 'libmapi.dll'; // Replace with the actual DLL name

type


  mapi = record

  end;

  MapiMsg = integer;


  MapiDate = record
    year  : smallint;
	  month : word;
	  day   : word;
  end;

  MapiTime = record
      hour : word;
	  minute : word;
	  second : word;
  end;


  MapiDateTime = record
      year  : smallint
	    month : word;
	      day : word;
	     hour : word;
	   minute : word;
	   second : word;
	 fraction : word;	//* in 1000 millionths of a second (10e-9) */
  end;

//* information about the columns in a result set */
  PMapiColumn = ^TMapiColumn ;
  TMapiColumn=record
	    tablename:pchar;
	   columnname:pchar;
	   columntype:pchar;
	 columnlength:integer;
	       digits:integer;
	        scale:integer;
  end;

//* information about bound columns */
  MapiBinding=record
	   outparam:Pointer;		//* pointer to application variable */
	    outtype:integer;		      //* type of application variable */
	  precision:integer;
	      scale:integer;
  end;

//* information about statement parameters */
  MapiParam =record
	    inparam:Pointer;		/* pointer to application variable */
	    sizeptr:Pinteger;		/* if string, points to length of string or -1 */
	     intype:integer;		//* type of application variable */
	    outtype:integer;		//* type of value */
	  precision:integer;
	      scale:integer;
  end;

{/*
 * The row cache contains a string representation of each (non-error) line
 * received from the backend. After a mapi_fetch_row() or mapi_fetch_field()
 * this string has been indexed from the anchor table, which holds a pointer
 * to the start of the field. A sliced version is recognized by looking
 * at the fldcnt table, which tells you the number of fields recognized.
 * Lines received from the server without 'standard' line headers are
 * considered a single field.
 */}
    Pline = ^TLine;
    Tline=record
       fldcnt : integer;	//* actual number of fields in each row */
		     rows : pchar;	  //* string representation of rows received */
	 tupleindex : integer;	//* index of tuple rows */
		 tuplerev : int64;	  //* reverse map of tupleindex */
//todo:		char **anchors;	      //* corresponding field pointers */
//todo:		size_t *lens;	        //* corresponding field lenghts */
    end;

  PMapiRowbuf  = ^TMapiRowBuf;
  TMapiRowBuf=record
	  rowlimit:integer;		//* maximum number of rows to cache */
	  limit:integer;		//* current storage space limit */
	  writer:integer;
	  reader:integer;
	  first:int64;		//* row # of first tuple */
 	  tuplecount:int64;	//* number of tuples in the cache */
    line:Pline;
  end;

PMapiResultSet = ^TMapiResultSet;
TMapiResultSet =record
	     next : PMapiResultSet;
	      hdl : PMapiStatement;
  	tableid : integer;		//* SQL id of current result set */
	querytype : integer;		//* type of SQL query */

	tuple_count : int64;
    row_count : int64;
	    last_id : int64;
	  querytime : int64;
	maloptimizertime:int64;
	sqloptimizertime:int64;
	fieldcnt : integer;
	maxfields : integer;

	errorstr:pchar;		//* error from server */
	sqlstate array [6] of char;	//* the SQL state code */
	fields:PmapiColumn;
	cache:TmapiRowbuf;
	commentonly:boolean;	//* only comments seen so far */
end;

PMapiStatement = ^TMapiStatement;
TMapiStatement =record
	struct MapiStruct *mid;
	char *template;		/* keep parameterized query text around */
	char *query;
	int maxbindings;
	int maxparams;
	struct MapiBinding *bindings;
	struct MapiParam *params;
	struct MapiResultSet *result, *active, *lastresult;
	int *pending_close;
	int npending_close;
	bool needmore;		/* need more input */
	bool aborted;		/* this query was aborted */
	MapiHdl prev, next;
end;


 BlockCache = record
	 buf : pchar;
	 lim : integer;
	 nxt : integer;
	 _end: integer;
	 eos : boolean;		//* end of sequence */
 end;

 mapi_lang_t = (LANG_MAL = 0,	LANG_SQL = 2,	LANG_PROFILER = 3)


{/* A connection to a server is represented by a struct MapiStruct.  An
   application can have any number of connections to any number of
   servers.  Connections are completely independent of each other.
*/}

 PMapiStruct = ^MapiStruct;
 MapiStruct = record
//todo:	msettings *settings;

       uri : pchar;
    server : pchar;		//* server version */
      motd : pchar;		//* welcome message from server */
 noexplain : pchar;	//* on error, don't explain, only print result */
	   error : MapiMsg;		//* Error occurred */
	errorstr : pchar;		//* error from server */
	const action:pchar;	//* pointer to constant string */

//todo:	struct BlockCache blk;
	connected : boolean;

	trace : boolean;		//* Trace Mapi interaction */
	handshake_options : integer;	//* which settings can be sent during challenge/response? */
	columnar_protocol : boolean;
  sizeheader : boolean;
	oobintr : boolean;

//todo:	MapiHdl first;		/* start of doubly-linked list */
//todo:	MapiHdl active;		/* set when not all rows have been received */

	redircnt : integer;		//* redirection count, used to cut of redirect loops */
	redirmax : integer;		//* maximum redirects before giving up */
//todo:#define MAXREDIR 50
//todo:	char *redirects[MAXREDIR];	//* NULL-terminated list of redirects */

	//todo: stream *tracelog;	//* keep a log for inspection */
	tracebuffer:pchar;	//* used for formatting to tracelog */

	tracebuffersize:integer; /* allocated size of tracebuffer */

	//todo: stream *from, *to;

	index:FixedUInt;		//* to mark the log records */
	filecontentprivate:Pointer;
	filecontentprivate_old:Pointer;
//todo:	char *(*getfilecontent)(void *, const char *, bool, uint64_t, size_t *);
//todo:	char *(*putfilecontent)(void *, const char *, bool, const void *, size_t);
//todo:	char *(*putfilecontent_old)(void *, const char *, const void *, size_t);

 end;


implementation

begin

end.
// Add function prototypes for the MonetDB MAPI DLL here
//function monetdb_startup(hostname: PAnsiChar; port: Integer; username, password: PAnsiChar): TMonetDBHandle; cdecl; external MonetDBAPILib;
//procedure monetdb_shutdown(handle: TMonetDBHandle); cdecl; external MonetDBAPILib;

// Add more function prototypes as needed


//Connecting and Disconnecting

//        Setup a connection with a Mserver at a host:port and login with username and password. If host == NULL, the local host is accessed. If host starts with a '/' and the system supports it,
//        host is actually the name of a UNIX domain socket, and port is ignored. If port == 0, a default port is used. If username == NULL, the username of the owner of the client application
//        containing the Mapi code is used. If password == NULL, the password is omitted. The preferred query language is any of {sql,mil,mal,xquery }.
//        On success, the function returns a pointer to a structure with administration about the connection.
function  mapi_connect(const host:Pchar, port:integer, username:Pchar, password:Pchar, lang:PChar, dbname:Pchar) :     Mapi; stdcall; external MonetDBAPILib;


//        Terminate the session described by mid. The only possible uses of the handle after this call is mapi_destroy() and mapi_reconnect(). Other uses lead to failure.
function  mapi_disconnect(mid:Mapi) :MapiMsg; stdcall; external MonetDBAPILib;


//        Terminate the session described by mid if not already done so, and free all resources. The handle cannot be used anymore.
function  mapi_destroy(mid:Mapi) :MapiMsg; stdcall; external MonetDBAPILib;


//        Close the current channel (if still open) and re-establish a fresh connection. This will remove all global session variables.
function mapi_reconnect(mid:Mapi):MapiMsg; stdcall; external MonetDBAPILib;


//       Test availability of the server. Returns zero upon success.
function mapi_ping(mid:Mapi):MapiMsg ; stdcall; external MonetDBAPILib;



//Sending Queries


//       Send the Command to the database server represented by mid. This function returns a query handle with which the results of the query can be retrieved. The handle should be closed with
//       mapi_close_handle(). The command response is buffered for consumption, c.f. mapi_fetch_row().
//    MapiHdl mapi_query(Mapi mid, const char *Command)


//       Send the Command to the database server represented by hdl, reusing the handle from a previous query. If Command is zero it takes the last query string kept around. The command response
//       is buffered for consumption, e.g. mapi_fetch_row().
//    MapiMsg mapi_query_handle(MapiHdl hdl, const char *Command)


//       Send the Command to the database server replacing the placeholders (?) by the string arguments presented.
//    MapiHdl mapi_query_array(Mapi mid, const char *Command, char **argv)


//       Similar to mapi_query(), except that the response of the server is copied immediately to the file indicated.
//    MapiHdl mapi_quick_query(Mapi mid, const char *Command, FILE *fd)


//       Similar to mapi_query_array(), except that the response of the server is not analyzed, but shipped immediately to the file indicated.
//    MapiHdl mapi_quick_query_array(Mapi mid, const char *Command, char **argv, FILE *fd)


//       Move the query to a newly allocated query handle (which is returned). Possibly interact with the back-end to prepare the query for execution.
//    MapiHdl mapi_prepare(Mapi mid, const char *Command)


//       Ship a previously prepared command to the backend for execution. A single answer is pre-fetched to detect any runtime error. MOK is returned upon success.
//    MapiMsg mapi_execute(MapiHdl hdl)


//       Similar to mapi_execute but replacing the placeholders for the string values provided.
//    MapiMsg mapi_execute_array(MapiHdl hdl, char **argv)


//       Terminate a query. This routine is used in the rare cases that consumption of the tuple stream produced should be prematurely terminated. It is automatically called when a new query using
//       the same query handle is shipped to the database and when the query handle is closed with mapi_close_handle().
//    MapiMsg mapi_finish(MapiHdl hdl)


//       Submit a table of results to the library that can then subsequently be accessed as if it came from the server. columns is the number of columns of the result set and must be greater than
//       zero. columnnames is a list of pointers to strings giving the names of the individual columns. Each pointer may be NULL and columnnames may be NULL if there are no names. tuplecount is
//       the length (number of rows) of the result set. If tuplecount is less than zero, the number of rows is determined by a NULL pointer in the list of tuples pointers. tuples is a list of
//       pointers to row values. Each row value is a list of pointers to strings giving the individual results. If one of these pointers is NULL it indicates a NULL/nil value.
//    MapiMsg mapi_virtual_result(MapiHdl hdl, int columns, const char **columnnames, const char **columntypes, const int *columnlengths, int tuplecount, const char ***tuples)



//Getting Results


//       Return the number of fields in the current row.
//    int mapi_get_field_count(MapiHdl mid)


//       If possible, return the number of rows in the last select call. A -1 is returned if this information is not available.
//    mapi_int64 mapi_get_row_count(MapiHdl mid)


//       If possible, return the last inserted id of auto_increment (or alike) column. A -1 is returned if this information is not available. We restrict this to single row inserts and one
//       auto_increment column per table. If the restrictions do not hold, the result is unspecified.
//    mapi_int64 mapi_get_last_id(MapiHdl mid)


//       Return the number of rows affected by a database update command such as SQL's INSERT/DELETE/UPDATE statements.
//    mapi_int64 mapi_rows_affected(MapiHdl hdl)


//       Retrieve a row from the server. The text retrieved is kept around in a buffer linked with the query handle from which selective fields can be extracted. It returns the number of fields
//       recognized. A zero is returned upon encountering end of sequence or error. This can be analyzed in using mapi_error().
//    int mapi_fetch_row(MapiHdl hdl)


//       All rows are cached at the client side first. Subsequent calls to mapi_fetch_row() will take the row from the cache. The number or rows cached is returned.
//    mapi_int64 mapi_fetch_all_rows(MapiHdl hdl)


//       Read the answer to a query and pass the results verbatim to a stream. The result is not analyzed or cached.
//    int mapi_quick_response(MapiHdl hdl, FILE *fd)


//       Reset the row pointer to the requested row number. If whence is MAPI_SEEK_SET, rownr is the absolute row number (0 being the first row); if whence is MAPI_SEEK_CUR, rownr is relative to
//       the current row; if whence is MAPI_SEEK_END, rownr is relative to the last row.
//    MapiMsg mapi_seek_row(MapiHdl hdl, mapi_int64 rownr, int whence)


//       Reset the row pointer to the first line in the cache. This need not be a tuple. This is mostly used in combination with fetching all tuples at once.
//    MapiMsg mapi_fetch_reset(MapiHdl hdl)

//       Return an array of string pointers to the individual fields. A zero is returned upon encountering end of sequence or error. This can be analyzed in using mapi_error().
//    char **mapi_fetch_field_array(MapiHdl hdl)


//        Return a pointer a C-string representation of the value returned. A zero is returned upon encountering an error or when the database value is NULL; this can be analyzed in using mapi_error().
//    char *mapi_fetch_field(MapiHdl hdl, int fnr)


//       Return the length of the C-string representation excluding trailing NULL byte of the value. Zero is returned upon encountering an error, when the database value is NULL, of when the string
//       is the empty string. This can be analyzed by using mapi_error() and mapi_fetch_field().
//    size_t mapi_fetch_fiels_len(MapiHdl hdl, int fnr)


//       Go to the next result set, discarding the rest of the output of the current result set.
//    MapiMsg mapi_next_result(MapiHdl hdl)


//Errors handling


//       Return the last error code or 0 if there is no error.
//    MapiMsg mapi_error(Mapi mid)


//       Return a pointer to the last error message.
//    const char *mapi_error_str(Mapi mid)


//       Return a pointer to the last error message from the server.
//    const char *mapi_result_error(MapiHdl hdl)


//       Return a pointer to the SQLSTATE code of the last error from the server.
//    const char *mapi_result_errorcode(MapiHdl hdl)


//       Write the error message obtained from mserver to a file.
//    void mapi_explain(Mapi mid, FILE *fd)

//       Write the error message obtained from mserver to a file.
//    void mapi_explain_query(MapiHdl hdl, FILE *fd)

//    Write the error message obtained from mserver to a file.
//    void mapi_explain_result(MapiHdl hdl, FILE *fd)


//Parameters


//       Bind a string variable with a field in the return table. Upon a successful subsequent mapi_fetch_row() the indicated field is stored in the space pointed to by val. Returns an error if
//       the field identified does not exist.
//    MapiMsg mapi_bind(MapiHdl hdl, int fldnr, char **val)


//       Bind a variable to a field in the return table. Upon a successful subsequent mapi_fetch_row(), the indicated field is converted to the given type and stored in the space pointed to by val.
//       The types recognized are ** MAPI_TINY, MAPI_UTINY, MAPI_SHORT, MAPI_USHORT, MAPI_INT, MAPI_UINT, MAPI_LONG, MAPI_ULONG, MAPI_LONGLONG, MAPI_ULONGLONG, MAPI_CHAR, MAPI_VARCHAR, MAPI_FLOAT,
//       MAPI_DOUBLE, MAPI_DATE, MAPI_TIME, MAPI_DATETIME**. The binding operations should be performed after the mapi_execute command. Subsequently all rows being fetched also involve delivery
//       of the field values in the C-variables using proper conversion. For variable length strings a pointer is set into the cache.
//    MapiMsg mapi_bind_var(MapiHdl hdl, int fldnr, int type, void *val)


//       Bind to a numeric variable, internally represented by MAPI_INT Describe the location of a numeric parameter in a query template.
//    MapiMsg mapi_bind_numeric(MapiHdl hdl, int fldnr, int scale, int precision, void *val)
//

//       Clear all field bindings.
//    MapiMsg mapi_clear_bindings(MapiHdl hdl)


//       Bind a string variable with the n-th placeholder in the query template. No conversion takes place.
//    MapiMsg mapi_param(MapiHdl hdl, int fldnr, char **val)


//       Bind a variable whose type is described by ctype to a parameter whose type is described by sqltype.
//    MapiMsg mapi_param_type(MapiHdl hdl, int fldnr, int ctype, int sqltype, void *val)


//       Bind to a numeric variable, internally represented by MAPI_INT.
//    MapiMsg mapi_param_numeric(MapiHdl hdl, int fldnr, int scale, int precision, void *val)


//       Bind a string variable, internally represented by MAPI_VARCHAR, to a parameter. The sizeptr parameter points to the length of the string pointed to by val.
//       If sizeptr == NULL or *sizeptr == -1, the string is NULL-terminated.
//    MapiMsg mapi_param_string(MapiHdl hdl, int fldnr, int sqltype, char *val, int *sizeptr)


//       Clear all parameter bindings.
//    MapiMsg mapi_clear_params(MapiHdl hdl)



//Miscellaneous

//       Set the autocommit flag (default is on). This only has effect when the language is SQL. In that case, the server commits after each statement sent to the server. information about autocommit and multi-statements transactions can be found here.
//    MapiMsg mapi_setAutocommit(Mapi mid, int autocommit)


//    Tell the backend to use or stop using the algebra-based compiler.
//    MapiMsg mapi_setAlgebra(Mapi mid, int algebra)


//       A limited number of tuples are pre-fetched after each execute(). If maxrows is negative, all rows will be fetched before the application is permitted to continue. Once the cache is filled,
//       a number of tuples are shuffled to make room for new ones, but taking into account non-read elements. Filling the cache quicker than reading leads to an error.
//    MapiMsg mapi_cache_limit(Mapi mid, int maxrows)


//       Forcefully shuffle the cache making room for new rows. It ignores the read counter, so rows may be lost.
//    MapiMsg mapi_cache_freeup(MapiHdl hdl, int percentage)


//       Escape special characters such as \n, \t in str with backslashes. The returned value is a newly allocated string which should be freed by the caller.
//    char * mapi_quote(const char *str, int size)


//       The reverse action of mapi_quote(), turning the database representation into a C-representation. The storage space is dynamically created and should be freed after use.
//    char * mapi_unquote(const char *name)


//       Set the output format for results send by the server.
//    MapiMsg mapi_output(Mapi mid, char *output)


//       Stream a document into the server. The name of the document is specified in docname, the collection is optionally specified in colname (if NULL, it defaults to docname),
//       and the content of the document comes from fp.
//    MapiMsg mapi_stream_into(Mapi mid, char *docname, char *colname, FILE *fp)


//       Set the profile flag to time commands send to the server.
//    MapiMsg mapi_profile(Mapi mid, int flag)


//    Set timeout in milliseconds for long-running queries.
//    MapiMsg mapi_timeout(Mapi mid, unsigned int time)


//    Set the trace flag to monitor interaction of the client with the library. It is primarily used for debugging Mapi applications.
//    void mapi_trace(Mapi mid, int flag)


//       Return the current value of the trace flag.
//    int mapi_get_trace(Mapi mid


//       Log the interaction between the client and server for offline inspection. Beware that the log file overwrites any previous log. For detailed interaction trace with the Mapi
//       library itself use mapi_trace().
//    MapiMsg mapi_log(Mapi mid, const char *fname)


implementation




end.






