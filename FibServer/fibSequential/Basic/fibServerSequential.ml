open Eio.Std
open Printf

let rec fib n =
  if n < 2 then 1
  else fib (n-1) + fib (n-2)


let main () =
      Eio_linux.run ( fun _env ->
        Eio.Std.Switch.run @@ fun sw ->
          let start = Unix.gettimeofday () in
          for i = 0 to 4 do
                Fiber.fork ~sw ( fun () -> 
                    (* let n = Random.int 5 in *)
                    let ans = fib (45) in
                    printf "\n%d Fiber Fib 45 : %d" i ans;
                    let stop = Unix.gettimeofday () in
                    Printf.printf "\n Fiber %d Response time: %fs\n\n\n%!" i (stop -. start)    
                );
          done
        )

  let _ = main ()