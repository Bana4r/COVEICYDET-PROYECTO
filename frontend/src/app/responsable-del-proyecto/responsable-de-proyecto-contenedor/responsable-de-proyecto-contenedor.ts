import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderRDP } from "../header-rdp/header-rdp"; // 👈 Ruta corregida

@Component({
  selector: 'app-responsable-de-proyecto-contenedor',
  standalone: true, // 👈 Igual standalone
  imports: [RouterOutlet, HeaderRDP],
  templateUrl: './responsable-de-proyecto-contenedor.html',
  styleUrls: ['./responsable-de-proyecto-contenedor.css']
})
export class ResponsableDeProyectoContenedor {}
