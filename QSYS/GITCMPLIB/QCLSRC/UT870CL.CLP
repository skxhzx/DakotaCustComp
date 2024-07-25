/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT870CL   Delete Item#'s with NDG in description.                */
/*  14 April 2003                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT870CL:    PGM

/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(UT870)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
