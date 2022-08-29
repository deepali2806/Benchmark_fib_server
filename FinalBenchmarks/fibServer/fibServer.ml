(* open Eio_linux *)
open Eio.Std
open Printf
(* open Batteries *)

(* let promises = BatDynArray.create () *)
let num_domains = try int_of_string Sys.argv.(1) with _ -> 2
let n = try int_of_string Sys.argv.(2) with _ -> 41
module T = Domainslib.Task


let rec fib n =
  if n < 2 then 1
  else fib (n-1) + fib (n-2)

let rec fib_par pool n =
  if n <= 40 then fib n
  else
    let a = T.async pool (fun _ -> fib_par pool (n-1)) in
    let b = T.async pool (fun _ -> fib_par pool (n-2)) in
    T.await pool a + T.await pool b

let m = Array.make 5 (Eio_domainslib_interface.MVar.create_empty ());;
(* let arr = Array.make 5   *)

let main () =
 let eio_domain = Domain.spawn( fun () ->
        Eio_linux.run ( fun _env ->
        Eio.Std.Switch.run @@ fun sw ->
            
            for i = 0 to 4 do
                Fiber.fork ~sw ( fun () -> 
                    let _ = Eio_domainslib_interface.MVar.put (40+i) (m.(i)) in
                    (* Adding Delay *)
                    for i = 0 to 10000 do
                        let _ = i in ()
                    done;
                    (* traceln "\nBefore mvar take%!"; *)
                );
            done
        ); 
    ) in ();

  let pool = T.setup_pool ~num_additional_domains:(num_domains - 1) () in
        T.run pool (fun () -> 
        let promises = Array.make 5 (T.async pool (fun _ -> ())) in

            for i = 0 to 4 do
            let a = T.async pool (fun _ -> 
                    let n = Eio_domainslib_interface.MVar.take (m.(i)) in
                    let v = fib_par pool (n) in
                    printf "\n%d Fib %d ans %d" i n v;
                ) in
                promises.(i) <- a;
                (* BatDynArray.add promises a; *)
            done;

            for i = 0 to 4 do
                (* let pr = BatDynArray.get promises i in *)
                let pr = promises.(i) in
                T.await pool pr;
            done;

        );
    let _ = Domain.join eio_domain in 
    printf "\nBoth the domains are done completed";

    T.teardown_pool pool

let  _ = main ()