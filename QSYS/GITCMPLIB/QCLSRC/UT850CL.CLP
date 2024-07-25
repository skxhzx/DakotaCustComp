/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT850CL   Change transaction status                              */
/*  07 February, 2001                                                */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT850CL:    PGM

/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(UT850)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
