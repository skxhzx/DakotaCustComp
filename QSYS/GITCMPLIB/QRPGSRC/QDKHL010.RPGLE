     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDKHL010  Extract data from ITEMADJ into IMPFPCKQ
     *  14 November 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  11/14/14  MLB  6.50
     *    - Created.
650aA*  11/17/14  MLB  6.50a
     *    - Enh: Revised pgm to correct start/end date/times for 2nd
     *      occurrence.
650bA*  11/19/14  MLB  6.50b
     *    - Enh: Revised pgm to correct start/end date/times for 3rd
     *      occurrence.
650cA*  12/02/14  MLB  6.50c
     *    - Enh: Revised pgm to correct start/end date/times for 4th
     *      occurrence.
650dA*  01/08/15  MLB  6.50d
     *    - Enh: Revised pgm to correct start/end date/times for 5th
     *      occurrence.
650eA*  02/12/15  MLB  6.50e
     *    - Enh: Revised pgm to correct start/end date/times for 6th
     *      occurrence.
650fA*  02/13/15  MLB  6.50f
     *    - Enh: Revised pgm to correct start/end date/times for 7th
     *      occurrence.
650gA*  02/24/15  MLB  6.50g
     *    - Enh: Revised pgm to correct start/end date/times for 02/24
     *      occurrence.
650hA*  03/18/15  MLB  6.50h
     *    - Enh: Revised pgm to correct start/end date/times for 03/18
     *      occurrence.
700 A*  04/28/15  MLB  7.00
     *    - Enh: Revised pgm to correct start/end date/times for 04/28
     *      occurrence.
700aA*  08/04/15  MLB  7.00a
     *    - Enh: Revised pgm to correct start/end date/times for 08/04
     *      occurrence.
700bA*  08/20/15  MLB  7.00b
     *    - Enh: Revised pgm to correct start/end date/times for 08/20
     *      occurrence.
700cA*  08/28/15  MLB  7.00c
     *    - Enh: Revised pgm to correct start/end date/times for 08/28
     *      occurrence.
700dA*  09/15/15  MLB  7.00d
     *    - Enh: Revised pgm to correct start/end date/times for 09/15
     *      occurrence.
700eA*  10/19/15  MLB  7.00e
     *    - Enh: Revised pgm to correct start/end date/times for 10/19
     *      occurrence.
700fA*  11/12/15  MLB  7.00f
     *    - Enh: Revised pgm to correct start/end date/times for 11/12
     *      occurrence.
700gA*  11/16/15  MLB  7.00g
     *    - Enh: Revised pgm to correct start/end date/times for 11/16
     *      occurrence.
700hA*  11/23/15  MLB  7.00h
     *    - Enh: Revised pgm to correct start/end date/times for 11/16
     *      occurrence. **** This reversal came after mods to FTP import
     *      script to submit call to HQ240CL to jobq instead of running
     *      pgm during FTP connection.  So, problem is not an issue of
     *      ftp connection timing out while processing data.
700iA*  09/23/16  MLB  7.00i
     *    - Enh: Revised pgm to correct start/end date/times for 09/23/16
     *      occurrence at 04:54:56.
700jA*  11/11/16  MLB  7.00k
     *    - Enh: Revised pgm to correct start/end date/times for 11/10/16
     *      occurrence at 13:57:42 - 13:58:11. Invoices sent from NDS
     *      test environment to BFC production environment in error.
     *
710 A*  04/04/17  MLB  7.10
     *    - Enh: Revised pgm to correct start/end date/times for 04/04/17
     *      occurrence at 13:47:40 - 13:49:06. Invoices duplicated from
     *      NDS due to errors in Production environment.
710aA*  08/18/17  MLB  7.10a
     *    - Enh: Revised pgm to correct start/end date/times for 08/17/17
     *      occurrence at 14:05:16 - 14:07:55. Invoices duplicated from
     *      NDS due to errors in Production environment.
     *
720 A*  03/08/18  MLB  7.20
     *    - Enh: Revised pgm to correct start/end date/times for 03/08/18
     *      occurrence at 17:35:29 - 17:44:19. Invoices needed to be
     *      reversed due to NDS errors in Production environment.
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *  - This program was created to extract adjustments that posted
     *    successfully via HQ245, but needed to be reversed because
     *    Host, NDS sent the same items twice.
     *
     *----------------------------------------------------------------

     fitemadj3  if   e           k disk
     fimpfpckq  o    e             disk
     *
     D kywhse          s              3  0
     D kydate          s              8  0
     *
     C     keyia         klist
     C                   kfld                    kywhse
     C                   kfld                    kydate
     *
     C                   eval      kywhse = 001
720 MC                   eval      kydate = 20180308
     C     keyia         setll     itemadj3
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      itemadj3
     C                   if        %eof(itemadj3)
     C                   leave
     C                   endif
     C*
720 MC                   if            iadate >= 20180308
720 MC                             and iadate <= 20180308
720 MC                             and iatime >= 173529
720 MC                             and iatime <= 174419
     C                             and (iacode =  'MV'
     C                               or iacode =  'MV')
     *
     c                   eval      ipqwhs = iawhse
     c                   eval      ipqwhd = iawhdp
     c                   eval      ipqdsp = iadisp
     c                   eval      ipqitm = iaitem
     c                   eval      ipqqp1 = iaqty1
     c                   eval      ipqqp2 = iaqty2
     c                   eval      ipqqp3 = iaqty3
     c                   eval      ipqadj = 'FX'
     c                   eval      ipqmem = iamemo
     c                   eval      ipqsof = 'Y'
     *
     c                   write     ipqrec
     *
     c                   endif
     *
     c                   enddo
     *
     C                   eval      *inlr = '1'
     *
