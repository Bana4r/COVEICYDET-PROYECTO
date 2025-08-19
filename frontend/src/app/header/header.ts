import { Component } from '@angular/core';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [RouterModule], // Import RouterModule para la navegacion
  templateUrl: './header.html',
  styleUrls: ['./header.css']  // Asegúrate de que el archivo CSS exista
})
export class Header {

}
