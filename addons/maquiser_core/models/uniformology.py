from odoo import models, fields

class Uniformology(models.Model):
    _name = 'maquiser.uniformology'
    _description = 'Diseños y especificaciones de uniformes'

    name = fields.Char(string='Nombre diseño', required=True)
    talla = fields.Selection([('S', 'S'), ('M', 'M'), ('L', 'L'), ('XL', 'XL')], string='Talla')
    material = fields.Char(string='Material')
    descripcion = fields.Text(string='Descripción')
    activo = fields.Boolean(string='Activo', default=True)
