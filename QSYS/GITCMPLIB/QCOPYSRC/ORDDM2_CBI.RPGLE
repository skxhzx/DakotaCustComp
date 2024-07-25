      *===================================================================
      *
      *  Name .......... ORDDM2_CBI
      *  Description ... Order Detail Misc. Field 2 - CBI
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
720   *   02/20/18  RTR  7.20
      *     - Created.
720a  *   05/24/18  NLK  7.20a
      *     - Enh: Ocala items being shipped by Riviera. OR610 needs
      *       stop number to process correct XDK slot for Cross-Dock.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     d orddm2_cbi      ds

     d  cbidm2_base                  40
     d*                                    text('Detail Misc 2 Field')

     dcbidm2_omcube                   7S 3 overlay(cbidm2_base:1)
     d*                                    text('Item Cube          ')
     dcbidm2_omswgt                   7S 2 overlay(cbidm2_base:8)
     d*                                    text('Item Weight        ')
720aAdcbidm2_ocastp                   3    overlay(cbidm2_base:15)
720aAd*                                    text('OCA Stop Number    ')
