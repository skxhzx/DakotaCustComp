/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDCCP001CL  Q&D Refresh PIRTESTF files from PIRF.                */
/*  29 June 2010                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    06/29/10  MLB  CCP                                             */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
PGM
             DCL        VAR(&WHSE) TYPE(*DEC) LEN(15 5) VALUE(001)
/*                                                                   */
             CPYF       FROMFILE(PIRF/PIRITEM) +
                          TOFILE(PIRTESTF/PIRITEM) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/ITEMMSC) +
                          TOFILE(PIRTESTF/ITEMMSC) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/ITEMQTY) +
                          TOFILE(PIRTESTF/ITEMQTY) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/ITEMLNK) +
                          TOFILE(PIRTESTF/ITEMLNK) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/ITEMDSC) +
                          TOFILE(PIRTESTF/ITEMDSC) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/ITEMFLD) +
                          TOFILE(PIRTESTF/ITEMFLD) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/KITCOMP) +
                          TOFILE(PIRTESTF/KITCOMP) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/SLOT   ) +
                          TOFILE(PIRTESTF/SLOT   ) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/VSLOT  ) +
                          TOFILE(PIRTESTF/VSLOT  ) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/LICACTIVE) +
                          TOFILE(PIRTESTF/LICACTIVE) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/LICLOG   ) +
                          TOFILE(PIRTESTF/LICLOG   ) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/LICENSE  ) +
                          TOFILE(PIRTESTF/LICENSE  ) MBROPT(*REPLACE)
/*                                                                           */
/*  Recompute warehouse qty to ensure whse/slot qty's are in sync.           */
             CALL       PGM(UT812) PARM(&WHSE '*ALL' 'Y' 'QDCCP001CL'  '' '')
ENDPGM
