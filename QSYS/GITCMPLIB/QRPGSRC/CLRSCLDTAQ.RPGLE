      //----------------------------------------------------------------
      //
      //  CLRSCLDTAQ    Clear Scale Data Queues
      //  16 November 2015
      //  Donnie Sanders
      //
      //  Revisions
      //
      //    11/16/15  DLS  7.00
      //     - Created
      //
      //----------------------------------------------------------------

      //----------------------------------------------------------------
      //  Prototypes
      //----------------------------------------------------------------
     D QCLRDTAQ        pr                  extpgm('QCLRDTAQ')
     D  prDQName                     10a   const
     D  prDQLibr                     10a   const

      //----------------------------------------------------------------
      //  Program Entry Point
      //----------------------------------------------------------------
     D CLRSCLDTAQ      pr                  extpgm('CLRSCLDTAQ')
     D  $DTAQ                        10a
     D  $DTAQLIB                     10a

     D CLRSCLDTAQ      pi
     D  $DTAQ                        10a
     D  $DTAQLIB                     10a

      //----------------------------------------------------------------
      //  Main line
      //----------------------------------------------------------------

      /Free
       // Call QCLRDTAQ
       QCLRDTAQ($DTAQ : $DTAQLIB);

       // End Of Program
       *inlr = *on;
       return;
      /End-Free
