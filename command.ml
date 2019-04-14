#load "unix.cma"
        
exception Cancel

let ls_dir dir exts =
  Sys.readdir dir
  |> Array.to_list
  |> List.filter (fun f -> List.mem (Filename.extension f) exts)
  |> List.sort compare

let lines_of_file path =

  let rec lines_of_file' channel lines = match input_line channel with
    | exception End_of_file -> List.rev lines
    | l -> lines_of_file' channel (l :: lines) in

  try
    let channel = open_in path in
    let lines = lines_of_file' channel [] in
    close_in channel ;
    lines
  with
  | Sys_error _ -> []
            
let output_of_command command =
  let cin = Unix.open_process_in command in
  try
    let output = input_line cin in
    let _ = Unix.close_process_in cin in
    output
  with
  | End_of_file -> raise Cancel

let program_is_running program =
  let ps = output_of_command ("ps -ef | grep -v grep | grep -cw "
                              ^ program) in
  String.length ps > 0
                         
let input_of_command writer command =
  let cout = Unix.open_process_out command in
  writer cout ;
  (match Unix.close_process_out cout with
   | Unix.WEXITED code when code = 0 -> ()
   | _ -> raise Cancel)
                         
let checklist_template height title subtitle choices =
  "zenity "
  ^ "--window-icon=question "
  ^ "--list "
  ^ "--checklist "
  ^ "--height=" ^ string_of_int height ^ " "
  ^ "--title=\"" ^ title ^ "\" "
  ^ "--column=\"\" "
  ^ "--column=\"" ^ subtitle ^ "\" "
  ^ choices

let progressbar_template title =
  "zenity "
  ^ "--progress "
  ^ "--title=\"" ^ title ^ "\" "
  ^ "--text=\"\" "
  ^ "--percentage=0 "
  ^ "--auto-close"

let info_template text =
  "zenity --info --text=" ^ text
