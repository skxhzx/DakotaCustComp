/*-------------------------------------------------------------------*/
/*                                                                   */
/*  WFSIGNON   Initial program to be call by Webfacing signon        */
/*  13 November 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*                                                                   */
/*  To get Webfacing to call this program instead of PIRMAIN         */
/*  go to /tomcat/webapps/DakotaWF/WEB-INF.                          */
/*  Next, edit file web.xml.                                         */
/*  Search for PIRMAIN. Should find a line with 'GO PIRMAIN'         */
/*  Copy that line.                                                  */
/*  Comment original line, using <!--  -->                           */
/*  Change GO PIRMAIN to CALL WFSIGNON                               */
/*                                                                   */
/*-------------------------------------------------------------------*/

 WFSIGNON:   PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Call a program */

       /*    CALL       PGM(????)  */

/*  Upon return, display menu */

             GO         MENU(PIRMAIN)

             ENDPGM
