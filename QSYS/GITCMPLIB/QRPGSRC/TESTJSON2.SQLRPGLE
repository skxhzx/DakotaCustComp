      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     h bnddir('YAJL')

     *----------------------------------------------------------------
     *  YAJL Header
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h

     d jsonStr         s           2048    varying
     d jsonList        s           2048    varying

     d yajlstat        s             10i 0

     d bufPointer      s               *   inz(%addr(bufString))
     d bufString       s           2048
     d strLen          s             10i 0
     d strLen2         s             10i 0

     d bufArray        s           3072
     d bufArrayPtr     s               *   inz(%addr(bufArray))
     d bufArrayLen     s             10i 0

     d Emsg            s            500    varying
     d JSONvar         s            500    varying
     d whouse          s              3    varying
     d transaction     s              7
     d eod             s              1
     d Oparm1          s             50    varying
     d Oparm2          s             50    varying
     d Oparm3          s             50    varying
     d Oparm4          s             50    varying
     d Oparm5          s             50    varying
     d Oparm6          s             50    varying
     d Oparm7          s             50    varying
     d Oparm8          s             50    varying
     d Oparm9          s             50    varying
     d Oparm10         s             50    varying
     d ONxtpgm         s             50    varying
     d Errmsg          s            500    varying

     d input_ds        ds
     d ds_lib                        10a
     d ds_prg                        10a
     d ds_user                       10a
     d ds_whouse                      3a
     d ds_tran                        7a
     d ds_eod                         1a
     d ds_uid                        32a
     d ds_wfrom                      20a
     d ds_f1f24                      24a
     d ds_Buttons                    26a


     d numZero         s              7  0
     d numQty          s              5  0

     D i               s             10i 0
     D j               s             10i 0
     D yajlErrmsg      s            500a   varying
     D docNode         s                   like(yajl_val)
     D inputNode       s                   like(yajl_val)
     D stdNode         s                   like(yajl_val)
     D node            s                   like(yajl_val)
     D list            s                   like(yajl_val)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Sub-Procedure Prototypes
     *----------------------------------------------------------------

     d LowerToUpper    pr         65535A   varying
     d  value                     65535A   varying const

     d SetPgmField     pr
     d  key                          50A   varying const
     d  value                              like(yajl_val) const


      /free

          //*Entry from Application

          JSONvar = '{"Std":{ +
                        "app":"SelectPrime", +
                        "user": "bfcdamcodv", +
                        "uid": "2ED4800E71821A6288B90004AC1D17AF", +
                        "whereFrom":"OR400.01", +
                        "whouse":"1"},+
                      "Input":{ +
                        "transaction":"439310", +
                        "eod":"N",+
                        "f1f24Click":"000000000001000000000000", +
                        "btnClick":"010011"} +
                      }';

          Exsr ParseJson;
          Exsr ParseJsonYAJL;
          Exsr CreateJson;

          *Inlr = *On;

     *****************************************************************
     * ParseJson - Parse JSON using SQL JSON_Table
     *****************************************************************

          BegSr ParseJson;
          //Parse it in local variable

           exec sql
            Select * into :input_ds
                   from JSON_Table(:JSONvar, '$' columns(
                        lib varchar(10) path '$.Input.lib',
                        prg varchar(10) path '$.Input.programme',
                        user varchar(10) path '$.Input.user',
                        whouse varchar(3) path '$.Input.Whouse',
                        Transaction varchar(7) path '$.Input.Transaction',
                        EOD varchar(1) path '$.Input.ds_Eod',
                        uid varchar(32) path '$.Input.ds_uid',
                        wfrom varchar(10) path '$.Input.whereFrom',
                        F1f24 varchar(24) path '$.F1F24',
                        N2550 varchar(26) path '$.N25N50' )) as T;

            sqlstt=sqlstt;
          EndSr;

     *****************************************************************
     * ParseJsonYAJL   Parse JSON using YAJL
     *****************************************************************

          BegSr ParseJsonYAJL;
          //Parse it in local variable

          // Load JSON string into memory and get pointer to root node/object

          docNode = yajl_string_load_tree( JSONvar : yajlErrMsg );

          if yajlErrmsg <> '';
            errmsg = 'Error loading JSON string';
          endif;

          // Get pointer to 'Input' node/object

          inputNode = yajl_object_find(docNode: 'Input');
          if inputNode = *null;
            errmsg = 'Object does not exist';
          endif;

          // Get pointer to 'Std' node/object

          stdNode = yajl_object_find(docNode: 'Std');
          if stdNode = *null;
            errmsg = 'Object does not exist';
          endif;

          // Get Std section

          errmsg = YAJL_stringifyStr(stdNode);

          // This supposedly uses less memory that YAJL_stringifyStr

          strLen = YAJL_stringify(stdNode: bufPointer: %len(bufString));
          jsonStr = %subst(bufString: 1: strLen);
          strLen = %len(jsonStr);

          // Get a specific field from Std object

          errmsg = jsonGetValue(stdNode: 'app');
          errmsg = jsonGetValue(stdNode: 'uid');
          errmsg = jsonGetValue(docNode: 'Std');

          // Test getting an invalid field

          errmsg = jsonGetValue(docNode: 'ABC');

          // Extract all fields from Std object

          jsonGetFields(stdNode);

          // Test of an invalid object name

          inputNode = yajl_object_find(docNode: 'XYZ');
          if inputNode = *null;
            errmsg = 'Object does not exist';
          endif;

          // Get a specific field from 'Input' object

          errmsg = jsonGetValue(inputNode: 'transaction');

          // Extract all fields from 'Input' object

          jsonGetFields(inputNode);

          // Free memory

          yajl_tree_free( docNode );

          EndSr;

     *****************************************************************
     * CreateJson   Create JSON string using YAJL
     *****************************************************************

          BegSr CreateJson;

           // Create just the array list
           // Even though we just want "prelist":[{"code"... ]
           // We need to create the beginning object {"prelist":[{"code"... ]}

           yajl_genOpen(*off);
             yajl_beginObj();
               yajl_beginArray('prelist');
                 yajl_beginObj();
                   yajl_addChar('code': 'ABC');
                   yajl_addChar('desc': 'Desc for ABC');
                 yajl_endObj();
                 yajl_beginObj();
                   yajl_addChar('code': 'XYZ');
                   yajl_addChar('desc': 'Desc for XYZ');
                 yajl_endObj();
               yajl_endArray();
             yajl_endObj();
           strLen2 = YAJL_copyBuf(0: bufArrayPtr: %len(bufArray): bufArrayLen);
           yajl_genClose();
           jsonStr = %subst(bufArray: 2: bufArrayLen-2);

           // When adding this to our Output JSON string, we only want the
           // array part [{"code": ... ]
           // Therefore, strip out the first part and the last }

           bufArray = %subst(bufArray: 12: bufArrayLen-12);
           bufArrayLen = %len(%trim(bufArray));

         // Create formatted 'Input' example. Write to IFS.

           yajl_genOpen(*On);
             yajl_beginObj();
               yajl_beginObj('Std');
                 yajl_addchar('app': 'SelectPrime');
                 yajl_addchar('user': %trim(ds_user));
                 yajl_addchar('uid': %trim(ds_uid));
                 yajl_addchar('whereFrom': %trim(ds_wfrom));
                 yajl_addchar('whouse': %trim(ds_whouse));
               yajl_endObj();
               yajl_beginObj('Input');
                 yajl_addchar('transaction': %trim(ds_tran));
                 yajl_addchar('eod': ds_eod);
                 yajl_addchar('f1f24Click': %trim(ds_f1f24));
                 yajl_addchar('btnClick': %trim(ds_Buttons));
               yajl_endObj();
             yajl_endObj();

           yajl_saveBuf('/tmp/example_input_formatted.json':Emsg);
           yajl_genClose();

           numZero = 0;
           numQty = 10;

         // Create formatted 'Output' example. Write to IFS.

           yajl_genOpen(*On);
             yajl_beginObj();
               yajl_beginObj('Std');
                 yajl_addchar('app': 'SelectPrime');
                 yajl_addchar('user': %trim(ds_user));
                 yajl_addchar('uid': %trim(ds_uid));
                 yajl_addchar('whereFrom': %trim(ds_wfrom));
                 yajl_addchar('whouse': %trim(ds_whouse));
               yajl_endObj();
               yajl_beginObj('Output');
                 yajl_addchar('nxtscr': 'OR400.6C');
                 yajl_addnum('w6qty': %char(numQty));
                 yajl_addnum('numZero': %char(numZero));
                 yajl_addchar('stop': '1');
                 yajl_addchar('slot': 'DA-101-1');
                 yajl_addchar('entryDesc': 'Enter Quantity Picked');
                 yajl_addchar('escapeTest': '[]{}<>,./\"!@#$%^&*()|:;?');
                 yajl_addchar('errmsg': 'Error: Invalid quantity picked');
                 yajl_beginArray('list');
                   yajl_beginObj();
                    yajl_addChar('slot': 'DA-101-1');
                    yajl_addChar('item': 'DA101');
                   yajl_endObj();
                   yajl_beginObj();
                    yajl_addChar('slot': 'DA-102-1');
                    yajl_addChar('item': 'DA102');
                   yajl_endObj();
                 yajl_endArray();
                 // Add array list created at beginning of routine
                 yajlstat = yajl_addPreformattedPtr('prelist':
                                                    bufArrayPtr: bufArrayLen);
               yajl_endObj();
               yajl_beginObj();
               yajl_endObj();
             yajl_endObj();

           yajl_saveBuf('/tmp/example_output_formatted.json':Emsg);
           yajl_genClose();


         // Create unformatted 'Output' example. Write to variable and IFS.

           yajl_genOpen(*OFF);
             yajl_beginObj();
               yajl_beginObj('Std');
                 yajl_addchar('app': 'SelectPrime');
                 yajl_addchar('user': %trim(ds_user));
                 yajl_addchar('uid': %trim(ds_uid));
                 yajl_addchar('whereFrom': %trim(ds_wfrom));
                 yajl_addchar('whouse': %trim(ds_whouse));
               yajl_endObj();
               yajl_beginObj('Output');
                 yajl_addchar('nxtscr': 'OR400.6C');
                 yajl_addnum('w6qty': %char(numQty));
                 yajl_addnum('numZero': %char(numZero));
                 yajl_addchar('stop': '1');
                 yajl_addchar('slot': 'DA-101-1');
                 yajl_addchar('entryDesc': 'Enter Quantity Picked');
                 yajl_addchar('escapeTest': '[]{}<>,./\"!@#$%^&*()|:;?');
                 yajl_addchar('errmsg': 'Error: Invalid quantity picked');
               yajl_endObj();
             yajl_endObj();

           jsonStr = YAJL_copyBufStr();
           strLen = %len(jsonStr);

           // The following supposedly uses less memory than YAJL_copyBufStr

           strLen2 = YAJL_copyBuf(0: bufPointer: %len(bufString): strLen);
           jsonStr = %subst(bufString: 1: strLen);
           strLen = %len(jsonStr);

           yajl_saveBuf('/tmp/example_output_compressed.json':Emsg);
           yajl_genClose();


          EndSr;
      /End-free


     *----------------------------------------------------------------
     * LowerToUpper   Convert lowercase to uppercase
     *----------------------------------------------------------------

     p LowerToUpper    b
     d LowerToUpper    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(lowercase: uppercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * SetPgmField      Set program field
     *----------------------------------------------------------------

     p SetPgmField     b
     d SetPgmField     pi
     d  key                          50A   varying const
     d  val                                like(yajl_val) const

      /free

        select;
          when key = 'user';
            ds_user = LowerToUpper(yajl_get_string(val));
          when key = 'uid';
            ds_uid = yajl_get_string(val);
          when key = 'whereFrom';
            ds_wfrom = yajl_get_string(val);
          when key = 'whouse';
            ds_whouse = yajl_get_string(val);
          when key = 'transaction';
            ds_tran = yajl_get_string(val);
          when key = 'eod';
            ds_eod = yajl_get_string(val);
          when key = 'f1f24Click';
            ds_f1f24 = yajl_get_string(val);
          when key = 'btnClick';
            ds_Buttons = yajl_get_string(val);
        endsl;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  JSON Subprocedures
     *----------------------------------------------------------------

      /copy qcopysrc,$jsonstr

