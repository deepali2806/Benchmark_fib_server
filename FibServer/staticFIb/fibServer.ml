open Eio.Std
open Printf
(* open Batteries *)

(* let promises = BatDynArray.create () *)
let num_domains = try int_of_string Sys.argv.(1) with _ -> 1
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


let no_Fibers = 5 
let values = Array.make no_Fibers (Eio_domainslib_interface.MVar.create_empty ());;
let result = Array.make no_Fibers (Eio_domainslib_interface.MVar.create_empty ());;
(* let arr = Array.make 5   *)

let main () =
 let eio_domain = Domain.spawn( fun () ->
        Eio_linux.run ( fun _env ->
        Eio.Std.Switch.run @@ fun sw ->
            
            for i = 0 to (no_Fibers-1) do
                Fiber.fork ~sw ( fun () -> 
                    let start = Unix.gettimeofday () in
                    
                    let n = (41 + i)  in
                    let _ = Eio_domainslib_interface.MVar.put n (values.(i)) in
                    (* Wait for answers *)
                    let ans = Eio_domainslib_interface.MVar.take (result.(i)) in 
                    printf "\nResult of fiber %d is Fib %d : %d\n%!" i n ans;
                    
                    let stop = Unix.gettimeofday () in
                    Printf.printf "\n Fiber %d Response time: %fs\n\n%!" i (stop -. start)
                );
                (* Adding Delay *)
                (* Unix.sleep 1; *)
                
            done
        ); 
    ) in 

    let pool = T.setup_pool ~num_additional_domains:(num_domains - 1) () 
    in
        T.run pool (fun () -> 
            T.parallel_for pool ~start:0 ~finish:(no_Fibers - 1) ~body:(fun i ->
                let pr = T.async pool ( fun _ ->
                        let n = Eio_domainslib_interface.MVar.take (values.(i)) in
                        let v = fib_par pool (n) in
                        let _ = Eio_domainslib_interface.MVar.put n (result.(i)) in
                        printf "\nDomainslib: %d Fib %d ans %d" i n v;
                    ) in
                let _ = T.await pool pr in ();
            ) 
    );
        
    let _ = Domain.join eio_domain in 
    printf "\nBoth the domains are done completed";
    T.teardown_pool pool

let  _ = main ()