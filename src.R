remove_seats <- function(seat_locations,radius) {
  accepted_seats <- seat_locations$n
  for (i in 1:length(accepted_seats)){
    num_to_remove <- c()
    
    if (i <= length(accepted_seats)){
      
      #go through each accepted node and determine if too close
      fixed_seat <- seat_locations[accepted_seats[i],]
      for (m in accepted_seats[i]:accepted_seats[length(accepted_seats)]){
        
        trial_seat <- seat_locations[m,]
        #if too close then a seat number to list
        if (((fixed_seat$x-trial_seat$x)^2 + (fixed_seat$y-trial_seat$y)^2) < radius^2 && fixed_seat$n != trial_seat$n){
          num_to_remove <- c(num_to_remove, m)
        }
      }
      
      #remove the nodes too close from the accepted list
      if (length(num_to_remove) > 0) {
        for (j in 1:length(accepted_seats)){
          for (k in 1:length(num_to_remove)){
            if (j  <= length(accepted_seats)){
              if (accepted_seats[j] == num_to_remove[k]){
                accepted_seats <- accepted_seats[accepted_seats!=num_to_remove[k]]
              }
            }
          }
        }
      }
    }
  }
  seat_locations[accepted_seats,]
}

remove_seats_shields <- function(seat_locations,radius,heatmaps) {
  accepted_seats <- seat_locations$n
  for (i in 1:length(accepted_seats)){
    num_to_remove <- c()
    
    if (i <= length(accepted_seats)){
      
      #go through each accepted node and determine if too close
      fixed_seat <- seat_locations[accepted_seats[i],]
      idx1 <- 1+100*(accepted_seats[i]-1)
      idx2 <- 100*(accepted_seats[i]-1) + 100
      xp <- heatmaps[1,idx1:idx2] 
      yp <- heatmaps[2,idx1:idx2]
      for (m in accepted_seats[i]:accepted_seats[length(accepted_seats)]){
        
        trial_seat <- seat_locations[m,]
        #if too close then a seat number to list
        if (inpolygon(trial_seat$x, trial_seat$y, xp, yp, boundary = TRUE) && fixed_seat$n != trial_seat$n){
          num_to_remove <- c(num_to_remove, m)
        }
      }
      
      #remove the nodes too close from the accepted list
      if (length(num_to_remove) > 0) {
        for (j in 1:length(accepted_seats)){
          for (k in 1:length(num_to_remove)){
            if (j  <= length(accepted_seats)){
              if (accepted_seats[j] == num_to_remove[k]){
                accepted_seats <- accepted_seats[accepted_seats!=num_to_remove[k]]
              }
            }
          }
        }
      }
    }
  }
  seat_locations[accepted_seats,]
}

heatmapper <- function(seat_locations,radius,domain_x,domain_y) {
  theta <- seq(0, 2*pi, length.out = 100)
  heatmaps <- array(numeric(),c(2,100*nrow(seat_locations)))
  for (j in 1:nrow(seat_locations)) {
    x_circle <- radius*cos(theta) + seat_locations[j,"x"]
    y_circle <- radius*sin(theta) + seat_locations[j,"y"]
    x_circle[x_circle<0] <- 0
    x_circle[x_circle>domain_x] <- domain_x
    y_circle[y_circle<0] <- 0
    y_circle[y_circle>domain_y] <- domain_y
    idx1 <- 1+100*(j-1)
    idx2 <- 100*(j-1) + 100
    heatmaps[1,idx1:idx2] <- x_circle
    heatmaps[2,idx1:idx2] <- y_circle
  }
  heatmaps
}

shielded_heatmapper <- function(seat_locations,shield,radius,domain_x,domain_y) {
  theta <- seq(0, 2*pi, length.out = 100)
  heatmaps <- array(numeric(),c(2,100*nrow(seat_locations)))
  for (j in 1:nrow(seat_locations)) {
    shield_interact <- c()
    x_circle <- radius*cos(theta) + seat_locations[j,"x"]
    y_circle <- radius*sin(theta) + seat_locations[j,"y"]
    x_circle[x_circle<0] <- 0
    x_circle[x_circle>domain_x] <- domain_x
    y_circle[y_circle<0] <- 0
    y_circle[y_circle>domain_y] <- domain_y
    for (i in 1:nrow(shield)) {
      shield_y <- seq(shield[i,3],shield[i,4],length.out=100)
      shield_x <- rep(shield[i,1],100)
      distance2 <- (shield_x-seat_locations[j,"x"])^2 + (shield_y-seat_locations[j,"y"])^2
      if (min(distance2) < radius^2) {
        if (shield[i,1] < seat_locations[j,"x"]) {     
          x_circle[x_circle<shield[i,1] & y_circle < max(shield_y) & y_circle>min(shield_y)] <- shield_x[x_circle < shield[i,1] & y_circle< max(shield_y) & y_circle> min(shield_y)]
        }
        else {
          x_circle[x_circle>shield[i,1] & y_circle < max(shield_y) & y_circle>min(shield_y)] <- shield_x[x_circle > shield[i,1] & y_circle< max(shield_y) & y_circle> min(shield_y)]
        }
      }
    }
    idx1 <- 1+100*(j-1)
    idx2 <- 100*(j-1) + 100
    heatmaps[1,idx1:idx2] <- x_circle
    heatmaps[2,idx1:idx2] <- y_circle
  }
  heatmaps
}



capacity <- function(width,length,radius) {
  first_x_node <- 0
  second_x_node <- (sqrt(2)/2)*radius
  third_x_node <- 0
  
  first_row <- c()
  second_row <- c()
  third_row <- c()
  
  if (sqrt(2)*radius<width) {
    while (first_x_node < length) {
      first_row <- c(first_row,first_x_node)
      first_x_node <- first_x_node + radius
    }
    while (second_x_node < length) {
      second_row <- c(second_row,second_x_node)
      second_x_node <- second_x_node + radius
    }
    while (third_x_node < length) {
      third_row <- c(third_row,third_x_node)
      third_x_node <- third_x_node + radius
    }
  } else {
    while (first_x_node < length) {
      first_row <- c(first_row,first_x_node)
      first_x_node <- first_x_node + radius
    }
    while (third_x_node < length) {
      third_row <- c(third_row,third_x_node)
      third_x_node <- third_x_node + radius
    }
  }
  length(c(first_row,second_row,third_row))
}


shield_locations_to_use <- function(shield_length,num_of_shields){
  for (i in 1:nrow(shield_locations)){
    if (i%%2 == 0){
      shield_locations[i,3] = shield_locations[i,3] + (1.16 - shield_length)
    }
    else{
      shield_locations[i,4] = shield_locations[i,4] - (1.16 - shield_length)
    }
    
  }
  
  shield_locations[1:num_of_shields,]
}



