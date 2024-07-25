/*-------------------------------------------------------------------*/
/*                                                                   */
/*  VC099CL   Vocollect Selection Test Only                          */
/*  18 December, 2000                                                */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 VC090CL:    PGM

/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(VC090)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(VCLABEL)
             CLRPFM     FILE(ORDC)

             ENDPGM
