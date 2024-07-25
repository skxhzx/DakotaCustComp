/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CPY2TESTF Copy files from PIRF to PIRTESTF                       */
/*  16 July, 2007                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CPY2TEST:

             CPYF       FROMFILE(PIRF/PIRITEM) +
                          TOFILE(PIRTESTF/PIRITEM) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)

             CPYF       FROMFILE(PIRF/ITEMMSC) +
                          TOFILE(PIRTESTF/ITEMMSC) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)

             CPYF       FROMFILE(PIRF/ITEMQTY) +
                          TOFILE(PIRTESTF/ITEMQTY) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)

             CPYF       FROMFILE(PIRF/ITEMDSC) +
                          TOFILE(PIRTESTF/ITEMDSC) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)

             CPYF       FROMFILE(PIRF/ITEMLNK) +
                          TOFILE(PIRTESTF/ITEMLNK) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)

             CPYF       FROMFILE(PIRF/SLOT) +
                          TOFILE(PIRTESTF/SLOT) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)

             CPYF       FROMFILE(PIRF/VSLOT) +
                          TOFILE(PIRTESTF/VSLOT) MBROPT(*REPLACE) +
                          FMTOPT(*MAP *DROP)


 NOMSG:

             ENDPGM
