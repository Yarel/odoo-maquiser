from odoo import models, fields

class UniformMeasurement(models.Model):
    _name = 'uniform.measurement'
    _description = 'Medidas para Uniformes'
    
    name = fields.Char('Nombre Plantilla')
    partner_id = fields.Many2one('res.partner', 'Cliente')
    chest = fields.Float('Pecho (cm)')
    waist = fields.Float('Cintura (cm)')
    # + otros campos de medidas
