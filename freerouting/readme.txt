Modifications par rapport à la version 1.4.4
---------------------------------------------
1 : le autorouteur ne démarre pas (bug #31 sur https://github.com/freerouting/freerouting)
Solution:

Ajouter result.set_stop_pass_no (99999) dans AutorouterSettings.java:

  else if (next_token == Keyword.START_PASS_NO)
  {
    result.set_start_pass_no(DsnFile.read_integer_scope(p_scanner));
    result.set_stop_pass_no (99999);
  }

---------------------------------------------
2: Supprimer le dialogue "Please confirm imported stored rules", lors de
   l'importation d'un fichier DSN

Dans MainApplication.java, commenter les lignes 366 à 390.

---------------------------------------------
3: Supprimer le dialogue "Save also the rules", lors de la sauvegarde d'un fichier SES

Dans DesignFiles.java, commenter les lignes 242 à 245.

//  if (WindowMessage.confirm(resources.getString("confirm")))
//  {
//    return write_rules_file(design_name, p_board_frame.board_panel.board_handling);
//  }

---------------------------------------------
4: Autoriser le départ d'une piste du côté le plus long d'un pad

Dans src/main/java/eu/mihosoft/freerouting/designforms/specctra/Structure.java, remplacer la ligne 1088.

 if (!smd_to_turn_gap_found)
  {
    //  p_board_rules.set_pin_edge_to_turn_dist(p_board_rules.get_min_trace_half_width());
        p_board_rules.set_pin_edge_to_turn_dist(0);
  }

---------------------------------------------
5: Réduire la taille de la fenêtre d'accueil

Dans MainApplication.java, commenter la ligne 276.

        this.addWindowListener(new WindowStateListener());
        pack();
  //      setSize(620,300);
    }
