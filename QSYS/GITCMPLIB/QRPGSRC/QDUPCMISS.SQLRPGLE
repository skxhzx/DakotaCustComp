      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
     *
     *
     * COMPILING. In order to compile this program you will need
     *            to use options which allow it to work correctly
     *            between machines. These options are---
     *
     *               COMMIT = *NONE
     *               RDB    = Machine name that you will connect to.
     *               DLYPRP = *YES
     *               SQLPKG = The name & library that you want to
     *                        use for the package. This will put the
     *                        package on the RDB machine that you
     *                        specify.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDUPCMISS   Identify items that need upc setup by uom
     *  10 May 2018
     *  Lynn McMahon
     *
720  *    05/10/18  LMC  7.20
     *      - Created
730aA*    07/31/19  LMC  7.30a
     *      - Added 3 New fields to identify which UOM is missing
740aA*    02/07/20  LMC  7.40a
     *      - Fix: flag wasn't being set on  properly for items where
     *        normal uom upc existed, but the breakdown was missing.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fpiritem1  if   e           k disk
     Fitemlnk1  if   e           k disk
     Fpiritem   if   e           k disk    prefix(ssb_) rename(itrec:itrec1)
730aDF*qdupcm    if a e           k disk
730aMFqdupcm    uf a e           k disk


     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D slrec         e ds                  extname(slot) inz(*EXTDFT)
     D uprec         e ds                  extname(upc) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------


      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *
      *    Returned Parameters
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------


      /free
        // process all but the SSB items
        dow forever = forever;
          read piritem1 ;
          if %eof(piritem1);
            leave;
          endif;
          if ittype = 'S';
            iter;
          endif;
          // is this item active - do I have it in a slot?
          exec sql select * into :slrec
               from slot
               where slitem = :ititem
                  and slpick = 'Y'
                 fetch first row only;

          if sqlstt = sqlSuccess;
730aA       qdmn = ' ';
730aA       qdm1 = ' ';
730aA       qdm2 = ' ';
            // found a slot
            // do I have the upc's loaded for normal uom
            exec sql select * into :uprec
                 from upc
                 where upitem = :ititem
                    and upuom  = :itum1
                   fetch first row only;
            if sqlstt <> sqlSuccess;
              // Need to write to work file
              QDWHDP  = ITWHDP;
              QDTYPE  = ITTYPE;
              QDITEM  = ITITEM;
              QDDESC  = ITDESC;
              QDUM1   = ITUM1;
              QDUM2   = ITUM2;
              QDFLG1  = ITFLG1;
              QDUM3   = ITUM3;
              QDFLG2  = ITFLG2;
              QDDISP  = SLDISP;
730aA         qdmn    = 'Y';
              write qdupcrec;
            endif;
            // do I have the upc's loaded for brk1 uom
            if itflg1 = 'Y';
              exec sql select * into :uprec
                   from upc
                   where upitem = :ititem
                      and upuom  = :itum2
                     fetch first row only;
              if sqlstt <> sqlSuccess;
                // Need to write to work file if the item isn't already there
730aA           // we will now update if record exist to identify which
730aA           // UOM is missing
                chain (ititem) qdupcm;
                if not %found(qdupcm);
                  QDWHDP  = ITWHDP;
                  QDTYPE  = ITTYPE;
                  QDITEM  = ITITEM;
                  QDDESC  = ITDESC;
                  QDUM1   = ITUM1;
                  QDUM2   = ITUM2;
                  QDFLG1  = ITFLG1;
                  QDUM3   = ITUM3;
                  QDFLG2  = ITFLG2;
                  QDDISP  = SLDISP;
740aA             qdm1 = 'Y';
                  write qdupcrec;
730aA           else;
730aA             qdm1 = 'Y';
730aA             update qdupcrec;
                endif;
              endif;
            endif;
            // do I have the upc's loaded for brk2 uom
            if itflg2 = 'Y';
              exec sql select * into :uprec
                   from upc
                   where upitem = :ititem
                      and upuom  = :itum3
                     fetch first row only;
              if sqlstt <> sqlSuccess;
                // Need to write to work file if the item isn't already there
                chain (ititem) qdupcm;
                if not %found(qdupcm);
                  QDWHDP  = ITWHDP;
                  QDTYPE  = ITTYPE;
                  QDITEM  = ITITEM;
                  QDDESC  = ITDESC;
                  QDUM1   = ITUM1;
                  QDUM2   = ITUM2;
                  QDFLG1  = ITFLG1;
                  QDUM3   = ITUM3;
                  QDFLG2  = ITFLG2;
                  QDDISP  = SLDISP;
740aA             qdm2 = 'Y';
                  write qdupcrec;
730aA           else;
730aA             qdm2 = 'Y';
730aA             update qdupcrec;
                endif;
              endif;
            endif;
            //  Now do I have a linked ssb item
            //  need to read each one and check if item is ssb
            setll (itwhse: ititem) itemlnk1;
            dow forever = forever;
              reade (itwhse: ititem) itemlnk1;
              if %eof(itemlnk1);
                leave;
              endif;
              // found one is it an ssb Item?
730aA       qdmn = ' ';
730aA       qdm1 = ' ';
730aA       qdm2 = ' ';
              chain (itwhse: ilitem) piritem;
              if %found(piritem);
                if ssb_ittype = 'S';
                  // do we have a upc loaded?
                  exec sql select * into :uprec
                       from upc
                       where upitem = :ssb_ititem
                          and upuom  = :ssb_itum1
                         fetch first row only;
                  if sqlstt <> sqlSuccess;
                    // Need to write to work file
                    QDWHDP  = ssb_ITWHDP;
                    QDTYPE  = ssb_ITTYPE;
                    QDITEM  = ssb_ititem;
                    QDDESC  = ssb_ITDESC;
                    QDUM1   = ssb_ITUM1;
                    QDUM2   = ssb_ITUM2;
                    QDFLG1  = ssb_ITFLG1;
                    QDUM3   = ssb_ITUM3;
                    QDFLG2  = ssb_ITFLG2;
                    QDDISP  = SLDISP;
730aA               qdm1    = 'Y';
                    write qdupcrec;
                  endif;
                endif;
              endif;
            enddo;
          endif;
        enddo;

        *inlr = *On;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------



