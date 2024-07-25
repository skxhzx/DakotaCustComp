/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BFCSQLLBCP   USE TO COMPILE RPG BFCSQLLIBR                       */
/*  16 May 2016                                                      */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*  05/09/16  KDE  7.00                                              */
/*    - Created.                                                     */
/*      Program BFCSQLLIBR uses a work file generated from           */
/*      DSPFD to get a member list from source file.  This CL        */
/*      creates and overrides to that to compile the RPG             */
/*                                                                   */
/*-------------------------------------------------------------------*/

             PGM

/*-------------------------------------------------------------------*/
/*  Mainline                                                         */
/*-------------------------------------------------------------------*/

             DSPFD      FILE(PIRSQL/QSQLSRC) TYPE(*MBRLIST) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/MBRLIST)
             OVRDBF     FILE(SRCFILE) TOFILE(QTEMP/MBRLIST)
             CRTSQLRPGI OBJ(PIRENH700/BFCSQLLIBR) +
                          SRCFILE(PIRENH700/QRPGSRC) SRCMBR(BFCSQLLIBR)
             DLTOVR     FILE(*ALL)
             DLTF       FILE(QTEMP/MBRLIST)

 ENDPGM:
