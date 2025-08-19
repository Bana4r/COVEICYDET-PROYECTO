import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RegistroProyecto3 } from './registro-proyecto3';

describe('RegistroProyecto3', () => {
  let component: RegistroProyecto3;
  let fixture: ComponentFixture<RegistroProyecto3>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RegistroProyecto3]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RegistroProyecto3);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
