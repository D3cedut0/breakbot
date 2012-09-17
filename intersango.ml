open Utils
open Common
open Intersango_parser

module MyBooks = struct
  let bid_books = Books.empty
  let ask_books = Books.empty

  let add_to_bid_books = Books.update bid_books
  let add_to_ask_books = Books.update ask_books
end

module Parser = Parser(MyBooks)

let print_to_stdout (ic, oc) : unit Lwt.t =
  let buf = Bi_outbuf.create 100 in
  let rec print_to_stdout () =
    lwt line = Lwt_io.read_line ic in
    let () = Parser.update_books (Yojson.Safe.from_string ~buf line) in
    lwt () = Lwt_io.printf "%s\n" line in
    print_to_stdout ()
  in print_to_stdout ()

let () =
  Sys.catch_break true;
  try
    let threads_to_run =
      [(with_connection "db.intersango.com" "1337" print_to_stdout)] in
    Lwt.join threads_to_run |> Lwt_main.run
  with Sys.Break ->
    print_endline "Bids"; Books.print MyBooks.bid_books;
    print_endline "Asks"; Books.print MyBooks.ask_books
