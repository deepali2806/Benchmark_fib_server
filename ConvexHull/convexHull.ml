open Batteries

(* Make it array of a pair *)
let pointArray:(int*int) DynArray.t  = BatDynArray.create ()
let convexHull = BatDynArray.create ()
let firstTransiotionPoint = ref 0
let secondTransitionPoint = ref 0

let take_input () = ()
  (* For now read it from file *)

(* Initialize convexHull with first 3 points of pointArray *)
let init () =
  let _ = take_input () in 
  for i = 0 to 2 do
    let x =  BatDynArray.get pointArray i in
    BatDynArray.set pointArray i x 
  done

  (* Find determinant value of |x2-x1  x3-x1 |
                                  | y2-y1 y3-y1 | *)
                                 
        (* TODO : Check for 0 value = When points are collinear *)
let checkIfInsideHull newPoint = 
  let tempFun () = 
    for i = 0 to ((BatDynArray.length convexHull) - 2) do
    begin
     let (x1, y1) = BatDynArray.get convexHull i in
     let (x2, y2) = BatDynArray.get convexHull (i+1) in
     let (x3, y3) = newPoint in
      let value = ((x2-x1)*(y3-y1) - (x3-x1)*(y2-y1)) in  
        (* If value is positive - It is a left value *)
          if (value > 0) then 
            begin
              (* Check the condition i.e. round about whe last point will be the  *)
              firstTransiotionPoint := i; 
              raise Exit
            end
    end
  done;
  true
in
  try tempFun () with
  | Exit -> false

 
let add_point convexHull pointArray i = 
    let newPoint = BatDynArray.get pointArray i in
    if (checkIfInsideHull newPoint) then
      (* Do nothing and go to the next point *)
      convexHull
    else
      begin     
        (* Find the nearest point from new point *)
        let smallestIndex = 
            let squareDistance point1 point2 = 
                let (x1, y1) = point1 in
                let (x2, y2) = point2 in 
                  (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
            in
            let rec  findMinIndex i minIndex = 
              if i = 0 then minIndex
              else
                begin
                  if (squareDistance newPoint (BatDynArray.get convexHull i) < squareDistance newPoint (BatDynArray.get convexHull minIndex)) then 
                    findMinIndex (i-1) i
                  else
                    findMinIndex (i-1) minIndex
                end
              in
              findMinIndex ((BatDynArray.length convexHull)-1) 0 in ();
              
              (* Find second  transition points  *)
              for j = (!firstTransiotionPoint+1)  to ((BatDynArray.length convexHull)-2) do
                let (x1, y1) = BatDynArray.get convexHull j in
                let (x2, y2) = BatDynArray.get convexHull (j+1) in
                let (x3, y3) = newPoint in
                let value = ((x2-x1)*(y3-y1) - (x3-x1)*(y2-y1)) in 
                (if value < 0 then
                  secondTransitionPoint := j)
              done;

              let _ = if (!secondTransitionPoint = 0) then
                secondTransitionPoint := (BatDynArray.length convexHull)-1
              in ();

              let _ = 
                if (!firstTransiotionPoint > !secondTransitionPoint) then
                begin
                  (* Swap *)
                  let temp = !firstTransiotionPoint in
                  firstTransiotionPoint := !secondTransitionPoint;
                  secondTransitionPoint := temp
                end 
              in ();

              (* Remove additional edges and add new point *)
              let convexHull = 
                (if (!firstTransiotionPoint <= smallestIndex && smallestIndex <= !secondTransitionPoint) then
                  begin
                    let newArr = BatDynArray.of_array [|(BatDynArray.get convexHull !firstTransiotionPoint); newPoint; (BatDynArray.get convexHull !secondTransitionPoint)|] in 
                    let leftArr = BatDynArray.left convexHull (!firstTransiotionPoint - 1) in
                    let rightArr = BatDynArray.right convexHull ((BatDynArray.length convexHull) - 1 - !secondTransitionPoint) in
                    BatDynArray.append newArr leftArr;
                    BatDynArray.append rightArr leftArr;
                    leftArr
                  end
              else
                begin
                  let arr = BatDynArray.sub convexHull (!firstTransiotionPoint) (!secondTransitionPoint - !firstTransiotionPoint+1) in
                    BatDynArray.add arr newPoint;
                    arr                  
                end) 
              in convexHull          
      end

let add_to_convex_hull convexHull pointArray = 
  for i = 3 to ((BatDynArray.length pointArray)-2) do
    let _ = add_point convexHull pointArray i in ()
  done