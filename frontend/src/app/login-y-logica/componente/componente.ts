import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Header } from "../header/header"; // Importar con el nombre correcto

@Component({
  selector: 'app-componente',
  imports: [RouterOutlet, Header],
  templateUrl: './componente.html',
  styleUrl: './componente.css'
})
export class Componente {

}
