/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDYHT010CL   Q&D Update PIRITEM/ITEMMSC Date Sensitive info      */
/*               for Kauai CHL dept items.                           */
/*                                                                   */
/*  19 September 2016                                                */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    09/19/16  MLB  YHT                                             */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDYHT011CL:    PGM        PARM(&ENV)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ENV)        TYPE(*CHAR) LEN(5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             SELECT
             WHEN       COND(&ENV = '*PROD') THEN(DO)

/*             From Warehouse Data                                            */
               OVRDBF     FILE(PIRITEM) TOFILE(PIRF/PIRITEM)
               OVRDBF     FILE(ITEMMSC) TOFILE(PIRF/ITEMMSC)

/*             To Warehouse Data                                              */
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRF004/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRF004/ITEMMSC1)

               CALL       PGM(QDYHT011)
             ENDdo

             WHEN       COND(&ENV = '*TEST') THEN(DO)

/*             From Warehouse Data                                            */
               OVRDBF     FILE(PIRITEM) TOFILE(PIRF/PIRITEM)
               OVRDBF     FILE(ITEMMSC) TOFILE(PIRF/ITEMMSC)

/*             To Warehouse Data                                              */
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRTSTF004/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRTSTF004/ITEMMSC1)

               CALL       PGM(QDYHT011)

             ENDdo

             ENDselect

             ENDPGM
