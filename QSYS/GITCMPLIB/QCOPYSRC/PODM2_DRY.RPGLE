      *===================================================================
      *
      *  Name .......... PODM2_DRY
      *  Description ... P/O Detail Misc. Field 2 - Dairyland Interface
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   08/28/13  MLB  6.50
      *     - Created.
      *
710 A *   07/24/17  MLB  7.10
      *     - Added 4 new fields: OSS Type, OSSRCV1, OSSRCV2, OSSRCV3.
      *       New fields will be used to send OSS quantity received on
      *       license plate to be sent to JDE in export file EXPSPOD.
      *
      *===================================================================
      *
      * Client Custom Revisions:
      *
xxx A *   mm/dd/yy  iii  ccc
      *     - insert chg text here.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D podm2_dry       ds

     D  drydm2_base                  40
     D*                                    text('Detail Misc 2 Field')
710 AD drydm2_osstype                 4a   overlay(drydm2_base:1)
710 AD*                                    text('OSS Type Code')
710 AD drydm2_ossrcv1                 7s 0 overlay(drydm2_base:5)
710 AD*                                    text('OSS Rcv Qty 1')
710 AD drydm2_ossrcv2                 7s 0 overlay(drydm2_base:12)
710 AD*                                    text('OSS Rcv Qty 2')
710 AD drydm2_ossrcv3                 7s 0 overlay(drydm2_base:19)
710 AD*                                    text('OSS Rcv Qty 3')
