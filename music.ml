(*  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

#use "command.ml"

exception Zero_playlists

let playlists_d = Sys.getenv "HOME" ^ "/.playlists.d/"
let history = playlists_d ^ ".history"
let exts = [".m3u"]
let win_height = 300
let seconds_before_start = 2

let player = "mocp"
let cmd_time = "mocp -Q %cs"
let sep_info = '/'
let cmd_info = "mocp -Q \""
               ^ "%song" ^ Char.escaped sep_info
               ^ "%artist" ^ Char.escaped sep_info
               ^ "%album\""
                   
let cmd_launch()   = Sys.command "mocp -S"
let cmd_add p      = Sys.command ("mocp -a " ^ p)
let cmd_stop()     = Sys.command "mocp -s"
let cmd_clear()    = Sys.command "mocp -c"
let cmd_play()     = Sys.command "mocp -p"
let cmd_next()     = Sys.command "mocp -f"
let cmd_toggle()   = Sys.command "mocp -G"
let cmd_previous() = Sys.command "mocp -r"
let cmd_repeat()   = Sys.command ("mocp -k -$(" ^ cmd_time ^ ")")

let opt_launch = "-l", "Launch playlists"
let opt_next   = "-n", "Skip forward"
let opt_back   = "-b", "Skip backward"
let opt_toggle = "-t", "Toggle play/pause"
let opt_info   = "-i", "Current song"
let opt_help   = "-h", "Help"
let opts = [opt_launch ; opt_next ; opt_back ; opt_toggle ;
            opt_info ; opt_help]
                 
let help() =
  let opts = List.map (fun (o,d) -> "  " ^ o ^ "    " ^ d) opts
             |> String.concat "\n" in
  let usage = "Usage: ocaml " ^ Sys.argv.(0) ^ " [OPTIONS]" ^ "\n\n"
              ^ "Options:" ^ "\n"
              ^ opts in
  prerr_endline usage

let launch_player () =
  if program_is_running player then () else ignore (cmd_launch())
    
let ls_playlists () =
  let playlists = ls_dir playlists_d exts in
  if List.length playlists = 0 then raise Zero_playlists else playlists

let playlists_of_history found_playlists =
  let former_playlists = lines_of_file history in
  List.filter (fun p -> List.mem p found_playlists) former_playlists

let tag_ok filename = true,  filename
let tag_ko filename = false, filename 
let untag (t,f) = if t then "TRUE " ^ f else "FALSE " ^ f
    
let tag_playlists select all = List.(
    if length select = 0
    then (tag_ok @@ hd all) :: (map tag_ko @@ tl all)
    else map (fun p -> if mem p select then tag_ok p else tag_ko p) all)

let select_playlists choices =
  let choices = List.map untag choices |> String.concat " " in
  let command = checklist_template win_height
                                   "Playlist selection"
                                   "Playlist"
                                   choices in
  output_of_command command |> String.split_on_char '|'

let add_playlists playlists =

  let delta = 100 / List.length playlists in
      
  let rec add_playlists' percent playlists cout = match playlists with
    | [] -> ()
    | h :: t -> output_string cout ("#Adding " ^ h ^ "\n") ;
                flush cout ;
                let _ = cmd_add (playlists_d ^ h) in
                let percent = percent + delta in
                output_string cout (string_of_int percent ^ "\n") ;
                flush cout ;
                add_playlists' percent t cout in

  progressbar_template "Processing..."
  |> input_of_command (add_playlists' 0 playlists)

let update_history selection =
  let selection = String.concat "\n" selection in
  let file = open_out history in
  output_string file selection
                
let launch() =
                  
  let launch'() =
    let _ = launch_player() in
    let playlists = ls_playlists() in
    let former_playlists = playlists_of_history playlists in
    let selected_playlists = tag_playlists former_playlists playlists
                             |> select_playlists in
    update_history selected_playlists ;
    let _ = cmd_stop(), cmd_clear() in
    add_playlists selected_playlists ;
    ignore (cmd_play()) in
  
  try
    launch'()
  with
  | Zero_playlists ->
     ignore @@ Sys.command (error_template "Zero playlists available")
  | Cancel -> ()

(* TODO : Message d'erreur si n'est pas lancé *)
let info() =
  let info =  "\""
              ^ (output_of_command cmd_info
                 |> String.map (fun c -> if c = sep_info then '\n' else c))
              ^  "\"" in
  ignore (Sys.command (info_template info))

let back() =
  let time = output_of_command cmd_time in
  if int_of_string time <= seconds_before_start
  then ignore (cmd_previous())
  else ignore (cmd_repeat()) ;;

match Array.to_list Sys.argv with
| [_ ; opt] when opt = fst opt_launch -> launch()
| [_ ; opt] when opt = fst opt_next -> ignore (cmd_next())
| [_ ; opt] when opt = fst opt_back -> back()
| [_ ; opt] when opt = fst opt_toggle -> ignore (cmd_toggle())
| [_ ; opt] when opt = fst opt_info -> info()
| _ -> help() ;;
