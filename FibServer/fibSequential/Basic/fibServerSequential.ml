open Eio.Std
open Printf

let rec fib n =
  if n < 2 then 1
  else fib (n-1) + fib (n-2)


let main () =
      Eio_linux.run ( fun _env ->
        Eio.Std.Switch.run @@ fun sw ->
          for i = 0 to 4 do
              let start = Unix.gettimeofday () in
                Fiber.fork ~sw ( fun () -> 
                    (* let n = Random.int 5 in *)
                    let start_c = Unix.gettimeofday () in
                    let ans = fib (41 + i) in
                    let stop_c = Unix.gettimeofday () in
                    printf "\n%d Fiber %d : %d" i (41+i) ans;
                    printf "\n Fiber %d Computation time: %fs\n%!" i (stop_c -. start_c)
                );
                let stop = Unix.gettimeofday () in
                Printf.printf "\n Fiber %d Response time: %fs\n\n\n%!" i (stop -. start)
            done
        )

  let _ = main ()