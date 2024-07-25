/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDYHT010CL   Q&D Update PIRITEM/ITEMMSC Date Sensitive info      */
/*               for Hilo CHL dept items.                            */
/*                                                                   */
/*  15 November 2012                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/15/12  MLB  YHT                                             */
/*      - Created.                                                   */
/*    04/28/16  MLB  YHTa                                            */
/*      - Revised pgm to run for Koapaka whse 3.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDYHT010CL:    PGM        PARM(&ENV)

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
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRF003/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRF003/ITEMMSC1)

               CALL       PGM(QDYHT010)
             ENDdo

             WHEN       COND(&ENV = '*TEST') THEN(DO)

/*             From Warehouse Data                                            */
               OVRDBF     FILE(PIRITEM) TOFILE(PIRF/PIRITEM)
               OVRDBF     FILE(ITEMMSC) TOFILE(PIRF/ITEMMSC)

/*             To Warehouse Data                                              */
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRTSTF003/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRTSTF003/ITEMMSC1)

               CALL       PGM(QDYHT010)

             ENDdo

             ENDselect

             ENDPGM
