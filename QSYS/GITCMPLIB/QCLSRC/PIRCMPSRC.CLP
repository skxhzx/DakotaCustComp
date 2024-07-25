/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIRCMPSRC   Compare source from individual libs to PIR lib       */
/*  06 June 2002                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PIRCMPSRC:  PGM

             CMPPFM     NEWFILE(PIRB/QCLSRC) NEWMBR(*ALL) +
                          OLDFILE(PIR/QCLSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBCL)

             CMPPFM     NEWFILE(PIRB/QCMDSRC) NEWMBR(*ALL) +
                          OLDFILE(PIR/QCMDSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBCMD)

             CMPPFM     NEWFILE(PIRB/QDDSFILES) NEWMBR(*ALL) +
                          OLDFILE(PIR/QDDSFILES) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBDDSF)

             CMPPFM     NEWFILE(PIRB/QDDSSRC) NEWMBR(*ALL) +
                          OLDFILE(PIR/QDDSSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBDDS)

             CMPPFM     NEWFILE(PIRB/QMENUSRC) NEWMBR(*ALL) +
                          OLDFILE(PIR/QMENUSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBMENU)

             CMPPFM     NEWFILE(PIRB/QMSGDSRC) NEWMBR(*ALL) +
                          OLDFILE(PIR/QMSGDSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBMSGD)

             CMPPFM     NEWFILE(PIRB/QRPGSRC) NEWMBR(*ALL) +
                          OLDFILE(PIR/QRPGSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRBRPG)



             CMPPFM     NEWFILE(PIREPM/QCLSRCE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QCLSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMCL)

             CMPPFM     NEWFILE(PIREPM/QCMDSRCE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QCMDSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMCMD)

             CMPPFM     NEWFILE(PIREPM/QDDSFILESE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QDDSFILES) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMDDSF)

             CMPPFM     NEWFILE(PIREPM/QDDSSRCE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QDDSSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMDDS)

             CMPPFM     NEWFILE(PIREPM/QMENUSRCE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QMENUSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMMENU)

             CMPPFM     NEWFILE(PIREPM/QMSGDSRCE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QMSGDSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMMSGD)

             CMPPFM     NEWFILE(PIREPM/QRPGSRCE) NEWMBR(*ALL) +
                          OLDFILE(PIR/QRPGSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIREPMRPG)



             CMPPFM     NEWFILE(PIRRFR/QCLSRCR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QCLSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRCL)

             CMPPFM     NEWFILE(PIRRFR/QCMDSRCR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QCMDSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRCMD)

             CMPPFM     NEWFILE(PIRRFR/QDDSFILESR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QDDSFILES) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRDDSF)

             CMPPFM     NEWFILE(PIRRFR/QDDSSRCR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QDDSSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRDDS)

             CMPPFM     NEWFILE(PIRRFR/QMENUSRCR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QMENUSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRMENU)

             CMPPFM     NEWFILE(PIRRFR/QMSGDSRCR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QMSGDSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRMSGD)

             CMPPFM     NEWFILE(PIRRFR/QRPGSRCR) NEWMBR(*ALL) +
                          OLDFILE(PIR/QRPGSRC) OUTPUT(*OUTFILE) +
                          OUTFILE(CMPLIBF/PIRRFRRPG)




             ENDPGM
