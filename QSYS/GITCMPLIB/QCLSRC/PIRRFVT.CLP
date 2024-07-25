/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRRFVGateway to PIR RF system.                               */
/*  09 May 1997                                                    */
/*  Dave Sommerville                                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 1997 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*  799 Roosevelt Rd.  Bldg 6, Suite 108                           */
/*  Glen Ellyn, IL  60137                                          */
/*  (708) 790-8383                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Notes:                                                         */
/*                                                                 */
/*-----------------------------------------------------------------*/

PIRRFH:      PGM

/*-----------------------------------------------------------------*/
/*  Setup library list for PIR and bring up first menu             */
/*-----------------------------------------------------------------*/

             CHGLIBL    LIBL(PIRWORKF +
                             PIRTESTF +
                             PIR220R +
                             PIR220E +
                             PIR220B +
                             PIRRFR +
                             PIREPM +
                             PIR +
                             PIRDAVE +
                             PIRTEST +
                             QGPL +
                             QTEMP) +
                             CURLIB(PIRWORK)

             CALL       RF840CL ('' '' '')

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
