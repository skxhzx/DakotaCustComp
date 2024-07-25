     h dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     h bnddir('YAJL')

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h

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
     d Errmsg          s            100    varying

     d input_ds        ds
     d ds_lib                        10a
     d ds_prg                        10a
     d ds_user                       10a
     d ds_whouse                      3a
     d ds_tran                        7a
     d ds_eod                         1a
     d ds_uid                        32a
     d ds_wfrom                      10a
     d ds_f1f24                      24a
     d ds_n2550                      26a

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      *
      /free

          //*Entry from Application

          JSONvar = '{"Input":{"lib": "PIRDAMV2","programme": "JSC01PR",+
                      "user": "BFCDAMCODV","Whouse":"1","Transaction":"439310",+
                      "Eod":"N","uid": "2ED4800E71821A6288B90004AC1D17AF",+
                      "whereFrom":"OR400.01"},  +
                      "F1F24":"000000000001000000000000", +
                      "N25N50":"00000000000100000000000011" }';

          Exsr ParseJson;
          Exsr Perfmlogic;
          Exsr CreateJson;

          *Inlr = *On;

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
                        EOD varchar(1) path '$.Input.Eod',
                        uid varchar(32) path '$.Input.uid',
                        wfrom varchar(10) path '$.Input.whereFrom',
                        F1f24 varchar(24) path '$.F1F24',
                        N2550 varchar(26) path '$.N25N50' )) as T;

            sqlstt=sqlstt;
          EndSr;

          Begsr Perfmlogic;
         // Perform logic

            Oparm1 = 'Slot: DA-106-1';
            Oparm2 = 'item: 33301 "{[description]}"';
            ONxtpgm = 'JSC12VPR';
            Errmsg = '';
         // ds_lib     = 'PIRDAMVDEV';
         // ds_prg     = 'JSC01PR';
         // ds_user    = 'BFCDAMCODV';
         // ds_whouse  = '001';
         // ds_tran    = '439310';
         // ds_eod     = 'N';
         // ds_uid     = '2ED4800E71821A6288B90004AC1D17AF';
         // ds_wfrom   = 'OR400.01';
         // ds_f1f24   = '000000000001000000000000';
         // ds_n2550   = '00000000000100000000000011';

          EndSr;

          BegSr CreateJson;
         // Create json to send back to Application

           yajl_genOpen(*On);
             yajl_beginObj();
               yajl_beginObj('Input');
                 yajl_addchar('library':ds_lib);
                 yajl_addchar('programme':ds_prg);
                 yajl_addchar('user':ds_user);
                 yajl_addchar('Whouse':ds_whouse);
                 yajl_addchar('Transaction':ds_tran);
                 yajl_addchar('Eod':ds_eod);
                 yajl_addchar('Uid':ds_uid);
                 yajl_addchar('Wherefrom':ds_wfrom);
                 yajl_addchar('funClick':ds_f1f24);
                 yajl_addchar('NfunClick':ds_n2550);
               yajl_endObj();
               yajl_beginObj('Output');
                 yajl_addchar('ONxtpgm': Onxtpgm);
                 yajl_addchar('Oparm1': Oparm1);
                 yajl_addchar('Oparm2': Oparm2);
                 yajl_addchar('Oparm3': Oparm3);
                 yajl_addchar('Oparm4': Oparm4);
                 yajl_addchar('Oparm5': Oparm5);
                 yajl_addchar('Oparm6': Oparm6);
                 yajl_addchar('Oparm7': Oparm7);
                 yajl_addchar('Oparm8': Oparm8);
                 yajl_addchar('Oparm9': Oparm9);
                 yajl_addchar('Oparm10': Oparm10);
               yajl_endObj();
               yajl_beginObj();
                 yajl_addchar('Errmsg': Errmsg);
               yajl_endObj();
             yajl_endObj();
           yajl_saveBuf('/tmp/test4.json':Emsg);
           yajl_genClose();

          EndSr;
      /End-free
