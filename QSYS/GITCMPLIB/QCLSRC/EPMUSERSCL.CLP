/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EPMUSERSL Query to display # of Users                            */
/*  06 January 2014                                                  */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  01/06/14  RH   6.50                                              */
/*   - Created                                                       */
/*   WRITES TO FILE EPMPUSERS IN QTEMP.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EPMUSERSCL:  PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Run query to get # of users for date&item range */

             RUNQRY     QRY(*LIBL/EPMUSERS) RCDSLT(*YES)

/* Run query to display # of users */

             RUNQRY     QRY(EPMUSERS1)


             ENDPGM
