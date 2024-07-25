/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FSI090CL  Food Star Interface Test                               */
/*  01 December, 2000                                                */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FSI090CL:   PGM

/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(FSI090)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
